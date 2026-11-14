$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Assert-Condition([bool]$Condition, [string]$Message) {
  if (-not $Condition) { throw "FAIL: $Message" }
  Write-Host "PASS: $Message" -ForegroundColor Green
}

Write-Host "NexusCloud validation" -ForegroundColor Cyan
docker compose config --quiet
Assert-Condition ($LASTEXITCODE -eq 0) "Compose configuration is valid"

$expectedContainers = @(
  "nexuscloud-app-a",
  "nexuscloud-app-b",
  "nexuscloud-blackbox",
  "nexuscloud-node-exporter",
  "nexuscloud-prometheus",
  "nexuscloud-grafana"
)
foreach ($name in $expectedContainers) {
  $state = docker inspect --format '{{.State.Status}}' $name 2>$null
  Assert-Condition ($LASTEXITCODE -eq 0 -and $state -eq "running") "$name is running"
}

foreach ($item in @(
  @{ Name = "Site A"; Url = "http://127.0.0.1:8081/" },
  @{ Name = "Site B"; Url = "http://127.0.0.1:8082/" },
  @{ Name = "Prometheus readiness"; Url = "http://127.0.0.1:9091/-/ready" },
  @{ Name = "Grafana health"; Url = "http://127.0.0.1:3001/api/health" }
)) {
  $response = Invoke-WebRequest -Uri $item.Url -UseBasicParsing -TimeoutSec 10
  Assert-Condition ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) "$($item.Name) returns HTTP $($response.StatusCode)"
}

$targets = Invoke-RestMethod -Uri "http://127.0.0.1:9091/api/v1/targets" -TimeoutSec 10
$active = @($targets.data.activeTargets)
Assert-Condition ($active.Count -eq 4) "Prometheus reports exactly four active targets"
$down = @($active | Where-Object { $_.health -ne "up" })
Assert-Condition ($down.Count -eq 0) "All Prometheus targets are UP"
$expectedJobs = @("prometheus", "node-exporter", "blackbox-site-a", "blackbox-site-b")
foreach ($job in $expectedJobs) {
  Assert-Condition (@($active | Where-Object { $_.labels.job -eq $job }).Count -eq 1) "Prometheus target exists: $job"
}

$rules = Invoke-RestMethod -Uri "http://127.0.0.1:9091/api/v1/rules" -TimeoutSec 10
$allRules = @($rules.data.groups | ForEach-Object { $_.rules })
Assert-Condition ($allRules.Count -eq 3) "Three Prometheus alert rules are loaded"
$badRules = @($allRules | Where-Object { $_.health -ne "ok" })
Assert-Condition ($badRules.Count -eq 0) "All Prometheus alert rules report healthy evaluation"

$networkA = (docker inspect --format '{{json .NetworkSettings.Networks}}' nexuscloud-app-a | ConvertFrom-Json).PSObject.Properties.Name
$networkB = (docker inspect --format '{{json .NetworkSettings.Networks}}' nexuscloud-app-b | ConvertFrom-Json).PSObject.Properties.Name
$networkBlackbox = (docker inspect --format '{{json .NetworkSettings.Networks}}' nexuscloud-blackbox | ConvertFrom-Json).PSObject.Properties.Name
Assert-Condition (($networkA -contains "nexuscloud-site-a") -and ($networkA -notcontains "nexuscloud-site-b")) "Site A is isolated on its own application bridge"
Assert-Condition (($networkB -contains "nexuscloud-site-b") -and ($networkB -notcontains "nexuscloud-site-a")) "Site B is isolated on its own application bridge"
Assert-Condition (($networkBlackbox -contains "nexuscloud-site-a") -and ($networkBlackbox -contains "nexuscloud-site-b") -and ($networkBlackbox -contains "nexuscloud-monitoring")) "Blackbox Exporter is attached to both site bridges and monitoring"

$crossA = docker exec nexuscloud-app-a sh -c "wget -q -T 2 -O /dev/null http://app-b:80 >/dev/null 2>&1"
$crossACode = $LASTEXITCODE
$crossB = docker exec nexuscloud-app-b sh -c "wget -q -T 2 -O /dev/null http://app-a:80 >/dev/null 2>&1"
$crossBCode = $LASTEXITCODE
Assert-Condition ($crossACode -ne 0) "Site A cannot resolve/reach Site B service"
Assert-Condition ($crossBCode -ne 0) "Site B cannot resolve/reach Site A service"

foreach ($mapping in @(
  @{ Container = "nexuscloud-app-a"; Expected = "127.0.0.1:8081" },
  @{ Container = "nexuscloud-app-b"; Expected = "127.0.0.1:8082" },
  @{ Container = "nexuscloud-grafana"; Expected = "127.0.0.1:3001" },
  @{ Container = "nexuscloud-prometheus"; Expected = "127.0.0.1:9091" },
  @{ Container = "nexuscloud-blackbox"; Expected = "127.0.0.1:9115" }
)) {
  $published = @(docker port $mapping.Container)
  $loopbackOnly = ($published.Count -eq 1) -and ($published[0] -match "->\s*127\.0\.0\.1:") -and ($published[0].Contains($mapping.Expected))
  Assert-Condition $loopbackOnly "$($mapping.Container) published only on expected loopback mapping"
}

Write-Host "PASS: all NexusCloud acceptance checks completed." -ForegroundColor Green
