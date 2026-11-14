param([switch]$IncludeWireGuard)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runDir = Join-Path $ProjectRoot "evidence\runs\$stamp"
New-Item -ItemType Directory -Force -Path $runDir | Out-Null
$transcript = Join-Path $runDir "validation-transcript.txt"
Start-Transcript -Path $transcript -Force | Out-Null
try {
  Write-Host "NexusCloud evidence run: $stamp"
  Write-Host "Repository commit:"
  git rev-parse HEAD
  Write-Host "Docker version:"
  docker version --format 'client={{.Client.Version}} server={{.Server.Version}}'
  Write-Host "Compose service status:"
  docker compose ps
  Write-Host "Running acceptance validation:"
  & (Join-Path $PSScriptRoot "validate.ps1")
  if ($LASTEXITCODE -ne 0) { throw "Validation script returned a non-zero exit code." }

  $summary = foreach ($container in @(
    "nexuscloud-app-a","nexuscloud-app-b","nexuscloud-blackbox",
    "nexuscloud-node-exporter","nexuscloud-prometheus","nexuscloud-grafana"
  )) {
    $obj = docker inspect $container | ConvertFrom-Json
    [pscustomobject]@{
      name = $obj[0].Name.TrimStart("/")
      state = $obj[0].State.Status
      health = if ($obj[0].State.Health) { $obj[0].State.Health.Status } else { "not-configured" }
      networks = @($obj[0].NetworkSettings.Networks.PSObject.Properties.Name)
      ports = @($obj[0].NetworkSettings.Ports.PSObject.Properties | ForEach-Object {
        $bindings = $_.Value
        if ($bindings) { $bindings | ForEach-Object { "$($_.HostIp):$($_.HostPort)" } }
      })
    }
  }
  $summary | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $runDir "container-summary.json")

  $targetData = Invoke-RestMethod "http://127.0.0.1:9091/api/v1/targets"
  $targetData.data.activeTargets | Select-Object @{n="job";e={$_.labels.job}}, @{n="instance";e={$_.labels.instance}}, health, lastScrape, lastError |
    Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $runDir "prometheus-targets.csv")
  $ruleData = Invoke-RestMethod "http://127.0.0.1:9091/api/v1/rules"
  $ruleData.data.groups | ForEach-Object { $_.rules } |
    Select-Object name, type, health, state, query |
    Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $runDir "prometheus-rules.csv")

  if ($IncludeWireGuard) {
    Write-Host "Running WireGuard namespace acceptance test."
    $wgLog = Join-Path $runDir "wireguard-test.txt"
    $wgErr = Join-Path $runDir "wireguard-stderr.txt"
    $proc = Start-Process -FilePath "wsl.exe" -ArgumentList @(
      "-d","Ubuntu","-u","root","--","bash",
      "/mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh","test"
    ) -Wait -PassThru -NoNewWindow -RedirectStandardOutput $wgLog -RedirectStandardError $wgErr
    if (Test-Path $wgErr) {
      Get-Content $wgErr | Add-Content -Path $wgLog
      Remove-Item $wgErr -Force
    }
    if ($proc.ExitCode -ne 0) { throw "WireGuard acceptance test failed with exit code $($proc.ExitCode)." }
    Get-Content $wgLog | Write-Host
  }

  Write-Host "Evidence written to $runDir"
  Write-Host "No .env contents or private key material were collected."
}
finally {
  Stop-Transcript | Out-Null
}
$rawTranscript = [System.IO.File]::ReadAllText($transcript)
$rawTranscript = $rawTranscript -replace '(?m)^Username:.*$', 'Username: [redacted]'
$rawTranscript = $rawTranscript -replace '(?m)^RunAs User:.*$', 'RunAs User: [redacted]'
$rawTranscript = $rawTranscript -replace '(?m)^Machine:.*$', 'Machine: [local host redacted]'
$rawTranscript = $rawTranscript -replace '(?m)^Host Application:.*$', 'Host Application: PowerShell evidence capture'
$rawTranscript = $rawTranscript -replace '(?m)^Process ID:.*$', 'Process ID: [redacted]'
$rawTranscript = [regex]::Replace($rawTranscript, '(?m)[ \t]+(?=\r?$)', '')
[System.IO.File]::WriteAllText($transcript, $rawTranscript, (New-Object System.Text.UTF8Encoding($false)))
