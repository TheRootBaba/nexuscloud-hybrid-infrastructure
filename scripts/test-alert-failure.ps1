param(
  [ValidateSet("SiteA","SiteB")]
  [string]$Site = "SiteA",
  [int]$TimeoutSeconds = 120,
  [int]$HoldFiringSeconds = 0
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$test = if ($Site -eq "SiteA") {
  @{ Container = "nexuscloud-app-a"; Alert = "SiteAUnavailable"; Job = "blackbox-site-a" }
} else {
  @{ Container = "nexuscloud-app-b"; Alert = "SiteBUnavailable"; Job = "blackbox-site-b" }
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runDir = Join-Path $ProjectRoot "evidence\runs\$stamp"
New-Item -ItemType Directory -Force -Path $runDir | Out-Null
$log = Join-Path $runDir "availability-failure-test.txt"
Start-Transcript -Path $log -Force | Out-Null
$stopped = $false

try {
  $state = docker inspect --format '{{.State.Status}}' $test.Container
  if ($LASTEXITCODE -ne 0 -or $state -ne "running") {
    throw "$($test.Container) must be running before the test."
  }

  Write-Host "Controlled failure test: $Site"
  Write-Host "Expected Prometheus alert: $($test.Alert)"
  Write-Host "Stopping $($test.Container) to trigger the HTTP probe alert."
  docker stop $test.Container | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "Could not stop $($test.Container)." }
  $stopped = $true

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  $firing = $false
  while ((Get-Date) -lt $deadline) {
    $alertData = Invoke-RestMethod "http://127.0.0.1:9091/api/v1/alerts" -TimeoutSec 10
    $match = @($alertData.data.alerts | Where-Object {
      $_.labels.alertname -eq $test.Alert -and $_.state -eq "firing"
    })
    if ($match.Count -gt 0) {
      $firing = $true
      break
    }
    Start-Sleep -Seconds 5
  }
  if (-not $firing) { throw "Expected alert $($test.Alert) did not enter firing state within $TimeoutSeconds seconds." }
  Write-Host "PASS: $($test.Alert) entered firing state while the site was stopped." -ForegroundColor Green
  if ($HoldFiringSeconds -gt 0) {
    Write-Host "Holding the alert firing for $HoldFiringSeconds seconds for evidence capture."
    Start-Sleep -Seconds $HoldFiringSeconds
  }

  Write-Host "Restoring $($test.Container)."
  docker start $test.Container | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "Could not restart $($test.Container)." }
  $stopped = $false

  $recoveryDeadline = (Get-Date).AddSeconds(90)
  $recovered = $false
  while ((Get-Date) -lt $recoveryDeadline) {
    $health = docker inspect --format '{{.State.Health.Status}}' $test.Container 2>$null
    $queryText = 'probe_success{job="' + $test.Job + '"}'
    $query = [uri]::EscapeDataString($queryText)
    $probe = Invoke-RestMethod "http://127.0.0.1:9091/api/v1/query?query=$query" -TimeoutSec 10
    $probeValue = if ($probe.data.result.Count -gt 0) { $probe.data.result[0].value[1] } else { "0" }
    if ($health -eq "healthy" -and $probeValue -eq "1") {
      $recovered = $true
      break
    }
    Start-Sleep -Seconds 5
  }
  if (-not $recovered) { throw "$Site did not recover to healthy state with a successful HTTP probe." }

  $alertData = Invoke-RestMethod "http://127.0.0.1:9091/api/v1/alerts" -TimeoutSec 10
  $stillFiring = @($alertData.data.alerts | Where-Object {
    $_.labels.alertname -eq $test.Alert -and $_.state -eq "firing"
  })
  if ($stillFiring.Count -gt 0) { throw "$($test.Alert) is still firing after recovery." }

  Write-Host "PASS: $Site container is healthy and its HTTP probe has recovered." -ForegroundColor Green
  Write-Host "PASS: $($test.Alert) is no longer firing." -ForegroundColor Green
  Write-Host "Evidence transcript: $log"
}
finally {
  if ($stopped) {
    Write-Host "Safety recovery: restarting $($test.Container)."
    docker start $test.Container | Out-Null
  }
  Stop-Transcript | Out-Null
  $raw = [System.IO.File]::ReadAllText($log)
  $raw = $raw -replace '(?m)^Username:.*$', 'Username: [redacted]'
  $raw = $raw -replace '(?m)^RunAs User:.*$', 'RunAs User: [redacted]'
  $raw = $raw -replace '(?m)^Machine:.*$', 'Machine: [local host redacted]'
  $raw = $raw -replace '(?m)^Host Application:.*$', 'Host Application: PowerShell alert test'
  $raw = $raw -replace '(?m)^Process ID:.*$', 'Process ID: [redacted]'
  $raw = [regex]::Replace($raw, '(?m)[ \t]+(?=\r?$)', '')
  [System.IO.File]::WriteAllText($log, $raw, (New-Object System.Text.UTF8Encoding($false)))
}
