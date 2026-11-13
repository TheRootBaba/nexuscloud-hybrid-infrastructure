$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw "Docker CLI not found." }
docker info | Out-Null
if (-not (Test-Path ".env")) {
  $Password = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
  "GRAFANA_ADMIN_PASSWORD=$Password" | Set-Content -Encoding ascii ".env"
  Write-Host "Created local .env with random Grafana password. Keep it private."
}
docker compose config | Out-Null
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw "Docker Compose failed." }
Write-Host "Started NexusCloud. Grafana http://localhost:3000 | Prometheus http://localhost:9090"
