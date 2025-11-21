# Script de pruebas de rendimiento básicas con PowerShell
# Ejecutar: .\pruebas-rendimiento-basicas.ps1

Write-Host "Iniciando pruebas de rendimiento..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5000"
$numRequests = 100
$resultados = @()

# Función para medir tiempo de respuesta
function Test-Endpoint {
    param($url, $nombre)
    
    Write-Host "Probando: $nombre" -ForegroundColor Yellow
    $tiempos = @()
    
    for ($i = 1; $i -le $numRequests; $i++) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        try {
            $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10 -ErrorAction Stop
            $stopwatch.Stop()
            
            if ($response.StatusCode -eq 200) {
                $tiempos += $stopwatch.ElapsedMilliseconds
            }
        }
        catch {
            Write-Host "   [ERROR] Error en request $i" -ForegroundColor Red
        }
        
        # Progress bar
        if ($i % 10 -eq 0) {
            Write-Host "   Progreso: $i/$numRequests requests" -ForegroundColor Gray
        }
    }
    
    # Calcular estadísticas
    if ($tiempos.Count -gt 0) {
        $promedio = ($tiempos | Measure-Object -Average).Average
        $minimo = ($tiempos | Measure-Object -Minimum).Minimum
        $maximo = ($tiempos | Measure-Object -Maximum).Maximum
        $p95 = $tiempos | Sort-Object | Select-Object -Index ([int]($tiempos.Count * 0.95))
        
        $resultado = [PSCustomObject]@{
            Endpoint = $nombre
            TotalRequests = $tiempos.Count
            Promedio = [math]::Round($promedio, 2)
            Minimo = $minimo
            Maximo = $maximo
            P95 = $p95
        }
        
        return $resultado
    }
    
    return $null
}

# Prueba 1: Página de inicio
Write-Host ""
$resultado1 = Test-Endpoint "$baseUrl/" "Página de Inicio"
if ($resultado1) { $resultados += $resultado1 }

# Prueba 2: API Productos
Write-Host ""
$resultado2 = Test-Endpoint "$baseUrl/api/producto" "API - Listar Productos"
if ($resultado2) { $resultados += $resultado2 }

# Prueba 3: API Servicios
Write-Host ""
$resultado3 = Test-Endpoint "$baseUrl/api/servicio" "API - Listar Servicios"
if ($resultado3) { $resultados += $resultado3 }

# Prueba 4: Login (POST)
Write-Host ""
Write-Host "Probando: API - Login" -ForegroundColor Yellow
$loginTiempos = @()
$loginBody = @{
    nombreUsuario = "admin"
    password = "admin123"
} | ConvertTo-Json

for ($i = 1; $i -le 50; $i++) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
        $stopwatch.Stop()
        $loginTiempos += $stopwatch.ElapsedMilliseconds
    }
    catch {
        Write-Host "   [ERROR] Error en request $i" -ForegroundColor Red
    }
    
    if ($i % 10 -eq 0) {
        Write-Host "   Progreso: $i/50 requests" -ForegroundColor Gray
    }
}

if ($loginTiempos.Count -gt 0) {
    $resultado4 = [PSCustomObject]@{
        Endpoint = "API - Login (POST)"
        TotalRequests = $loginTiempos.Count
        Promedio = [math]::Round(($loginTiempos | Measure-Object -Average).Average, 2)
        Minimo = ($loginTiempos | Measure-Object -Minimum).Minimum
        Maximo = ($loginTiempos | Measure-Object -Maximum).Maximum
        P95 = $loginTiempos | Sort-Object | Select-Object -Index ([int]($loginTiempos.Count * 0.95))
    }
    $resultados += $resultado4
}

# Mostrar resultados
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "RESULTADOS DE PRUEBAS DE RENDIMIENTO" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

$resultados | Format-Table -AutoSize

# Análisis
Write-Host ""
Write-Host "ANALISIS:" -ForegroundColor Green
Write-Host ""

foreach ($r in $resultados) {
    $status = if ($r.Promedio -lt 100) { "[OK] Excelente" }
              elseif ($r.Promedio -lt 300) { "[BIEN] Bueno" }
              elseif ($r.Promedio -lt 1000) { "[WARN] Aceptable" }
              else { "[LENTO] Requiere optimizacion" }
    
    $color = if ($r.Promedio -lt 100) { "Green" }
             elseif ($r.Promedio -lt 300) { "Yellow" }
             else { "Red" }
    
    Write-Host "  $($r.Endpoint): $status ($($r.Promedio) ms promedio)" -ForegroundColor $color
}

# Guardar reporte
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportePath = "reporte-rendimiento_$fecha.txt"

$reporte = @"
======================================================
REPORTE DE PRUEBAS DE RENDIMIENTO
======================================================
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Servidor: $baseUrl
Total de Endpoints Probados: $($resultados.Count)

RESULTADOS:
$($resultados | Format-Table -AutoSize | Out-String)

RECOMENDACIONES:
- Promedio menor a 100ms: Excelente [OK]
- Promedio 100-300ms: Bueno [BIEN]
- Promedio 300-1000ms: Aceptable [WARN]
- Promedio mayor a 1000ms: Requiere optimizacion [LENTO]

"@

$reporte | Out-File -FilePath $reportePath -Encoding UTF8

Write-Host ""
Write-Host "Reporte guardado en: $reportePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pruebas completadas!" -ForegroundColor Green
