# Script para ejecutar pruebas de rendimiento con Newman
# Requiere: npm install -g newman newman-reporter-htmlextra

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Pruebas de Rendimiento con Newman" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Newman está instalado
try {
    $newmanVersion = newman --version
    Write-Host "[OK] Newman instalado: v$newmanVersion" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Newman no está instalado" -ForegroundColor Red
    Write-Host "Instalar con: npm install -g newman" -ForegroundColor Yellow
    exit 1
}

# Verificar si el servidor está corriendo
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[OK] Servidor corriendo en http://localhost:5000" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Servidor no está corriendo" -ForegroundColor Red
    Write-Host "Ejecuta primero: dotnet run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Iniciando pruebas de rendimiento..." -ForegroundColor Cyan
Write-Host ""

# Ejecutar Newman con diferentes configuraciones
$collectionPath = "postman-collection.json"
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Test 1: Prueba ligera (10 iteraciones)
Write-Host "[1/3] Prueba ligera: 10 iteraciones..." -ForegroundColor Yellow
newman run $collectionPath `
    -n 10 `
    --delay-request 100 `
    --timeout-request 10000 `
    --reporters cli

Write-Host ""

# Test 2: Prueba media (50 iteraciones)
Write-Host "[2/3] Prueba media: 50 iteraciones..." -ForegroundColor Yellow
newman run $collectionPath `
    -n 50 `
    --delay-request 50 `
    --timeout-request 10000 `
    --reporters cli

Write-Host ""

# Test 3: Prueba intensiva (100 iteraciones con reporte HTML)
Write-Host "[3/3] Prueba intensiva: 100 iteraciones (generando reporte HTML)..." -ForegroundColor Yellow
$reportPath = "newman-report_$fecha.html"

try {
    newman run $collectionPath `
        -n 100 `
        --delay-request 50 `
        --timeout-request 10000 `
        --reporters cli,htmlextra `
        --reporter-htmlextra-export $reportPath
    
    Write-Host ""
    Write-Host "[OK] Reporte HTML generado: $reportPath" -ForegroundColor Green
}
catch {
    # Si htmlextra no está instalado, usar reporte básico
    Write-Host "[WARN] newman-reporter-htmlextra no instalado, usando reporte básico" -ForegroundColor Yellow
    
    newman run $collectionPath `
        -n 100 `
        --delay-request 50 `
        --timeout-request 10000 `
        --reporters cli,html `
        --reporter-html-export $reportPath
    
    Write-Host ""
    Write-Host "[OK] Reporte HTML generado: $reportPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Pruebas completadas" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para instalar reportes avanzados:" -ForegroundColor Yellow
Write-Host "npm install -g newman-reporter-htmlextra" -ForegroundColor Gray
Write-Host ""

# Abrir reporte en navegador
$openReport = Read-Host "Abrir reporte en navegador? (S/N)"
if ($openReport -eq "S" -or $openReport -eq "s") {
    Start-Process $reportPath
}
