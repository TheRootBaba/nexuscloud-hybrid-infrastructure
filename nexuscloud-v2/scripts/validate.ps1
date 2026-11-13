$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot
docker compose config | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Compose configuration invalid." }
$checks = @(
  @{ Name = "Site A"; Url = "http://127.0.0.1:8081/" },
  @{ Name = "Site B"; Url = "http://127.0.0.1:8082/" },
  @{ Name = "Prometheus"; Url = "http://127.0.0.1:9090/-/ready" },
  @{ Name = "Grafana"; Url = "http://127.0.0.1:3000/api/health" }
)
foreach ($check in $checks) {
  $response = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec 10
  if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 400) { throw "$($check.Name) failed." }
  Write-Host "PASS $($check.Name): HTTP $($response.StatusCode)"
}
$targets = Invoke-RestMethod -Uri "http://127.0.0.1:9090/api/v1/targets"
$down = @($targets.data.activeTargets | Where-Object { $_.health -ne "up" })
if ($down.Count -gt 0) { throw "Prometheus has $($down.Count) target(s) not UP." }
Write-Host "PASS: all Prometheus targets are UP."
