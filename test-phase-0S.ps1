Write-Host "=== FLOWFORGE INFRASTRUCTURE TEST ===" -ForegroundColor Cyan
cd shared-infrastructure
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d
Write-Host "Waiting 60 seconds..." -ForegroundColor Gray
Start-Sleep -Seconds 60
Write-Host "Running health checks..." -ForegroundColor Yellow
try { $ollama = Invoke-RestMethod http://localhost:11434/api/tags; Write-Host "Ollama: OK" -ForegroundColor Green } catch { Write-Host "Ollama: FAIL" -ForegroundColor Red }
try { $ragna = Invoke-RestMethod http://localhost:31476/health; Write-Host "RAGNA: OK" -ForegroundColor Green } catch { Write-Host "RAGNA: FAIL" -ForegroundColor Red }
try { Invoke-WebRequest http://localhost:9090/-/healthy -UseBasicParsing | Out-Null; Write-Host "Prometheus: OK" -ForegroundColor Green } catch { Write-Host "Prometheus: FAIL" -ForegroundColor Red }
try { Invoke-RestMethod http://localhost:3000/api/health | Out-Null; Write-Host "Grafana: OK" -ForegroundColor Green } catch { Write-Host "Grafana: FAIL" -ForegroundColor Red }
cd ..
