# PRUEBAS DE RENDIMIENTO COMPLETAS - Sistema de Gestión de Taller Mecánico
# Este script prueba TODOS los componentes del sistema

param(
    [int]$RequestsPorEndpoint = 50,
    [int]$DelayMs = 50
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PRUEBAS DE RENDIMIENTO COMPLETAS" -ForegroundColor Cyan
Write-Host "  Sistema de Gestion de Taller Mecanico" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  - Requests por endpoint: $RequestsPorEndpoint" -ForegroundColor Gray
Write-Host "  - Delay entre requests: $DelayMs ms" -ForegroundColor Gray
Write-Host ""

$baseUrl = "http://localhost:5000"
$todosLosResultados = @()
$errorLog = @()

# Verificar servidor
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] Servidor respondiendo en $baseUrl" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Servidor no responde. Ejecuta 'dotnet run' primero" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Iniciando pruebas..." -ForegroundColor Cyan
Write-Host ""

# Función mejorada para medir tiempos
function Test-Endpoint {
    param(
        [string]$url,
        [string]$nombre,
        [string]$metodo = "GET",
        [object]$body = $null,
        [int]$numRequests = $RequestsPorEndpoint
    )
    
    Write-Host ">> Probando: $nombre" -ForegroundColor Yellow
    Write-Host "   URL: $metodo $url" -ForegroundColor Gray
    
    $tiempos = @()
    $errores = 0
    
    for ($i = 1; $i -le $numRequests; $i++) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        try {
            if ($metodo -eq "GET") {
                $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10 -ErrorAction Stop
            }
            elseif ($metodo -eq "POST" -or $metodo -eq "PUT") {
                $jsonBody = $body | ConvertTo-Json -Depth 10
                $response = Invoke-RestMethod -Uri $url -Method $metodo -Body $jsonBody -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
            }
            elseif ($metodo -eq "DELETE") {
                $response = Invoke-WebRequest -Uri $url -Method DELETE -TimeoutSec 10 -ErrorAction Stop
            }
            
            $stopwatch.Stop()
            $tiempos += $stopwatch.ElapsedMilliseconds
            
            Start-Sleep -Milliseconds $DelayMs
        }
        catch {
            $stopwatch.Stop()
            $errores++
            $script:errorLog += "[ERROR] $nombre - Request $i : $($_.Exception.Message)"
        }
        
        if ($i % 10 -eq 0) {
            Write-Host "   Progreso: $i/$numRequests" -ForegroundColor DarkGray
        }
    }
    
    # Calcular estadísticas
    if ($tiempos.Count -gt 0) {
        $stats = $tiempos | Measure-Object -Average -Minimum -Maximum
        $promedio = [math]::Round($stats.Average, 2)
        $minimo = $stats.Minimum
        $maximo = $stats.Maximum
        $p95 = if ($tiempos.Count -ge 2) { $tiempos | Sort-Object | Select-Object -Index ([int]($tiempos.Count * 0.95)) } else { $maximo }
        $p99 = if ($tiempos.Count -ge 2) { $tiempos | Sort-Object | Select-Object -Index ([int]($tiempos.Count * 0.99)) } else { $maximo }
        $tasaExito = [math]::Round((($tiempos.Count / $numRequests) * 100), 2)
        
        $resultado = [PSCustomObject]@{
            Componente = $nombre
            Metodo = $metodo
            TotalRequests = $numRequests
            Exitosos = $tiempos.Count
            Fallidos = $errores
            TasaExito = "$tasaExito%"
            Promedio = $promedio
            Minimo = $minimo
            Maximo = $maximo
            P95 = $p95
            P99 = $p99
        }
        
        # Mostrar resultado inmediato
        $status = if ($promedio -lt 100) { "[EXCELENTE]" }
                  elseif ($promedio -lt 300) { "[BUENO]" }
                  elseif ($promedio -lt 1000) { "[ACEPTABLE]" }
                  else { "[LENTO]" }
        
        $color = if ($promedio -lt 100) { "Green" }
                 elseif ($promedio -lt 300) { "Yellow" }
                 else { "Red" }
        
        Write-Host "   $status Promedio: $promedio ms | Exito: $tasaExito%" -ForegroundColor $color
        Write-Host ""
        
        return $resultado
    }
    
    Write-Host "   [ERROR] Todas las peticiones fallaron" -ForegroundColor Red
    Write-Host ""
    return $null
}

# ============================================================
# CATEGORIA 1: PAGINAS PRINCIPALES (Frontend)
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 1: PAGINAS PRINCIPALES (Frontend Blazor)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/" "Pagina de Inicio" "GET" $null 30
if ($r) { $todosLosResultados += $r }

$r = Test-Endpoint "$baseUrl/login" "Pagina de Login" "GET" $null 30
if ($r) { $todosLosResultados += $r }

# ============================================================
# CATEGORIA 2: API DE AUTENTICACION
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 2: API DE AUTENTICACION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Note: Login POST tiene problemas con PowerShell, se prueba mejor con Postman/Newman

# ============================================================
# CATEGORIA 3: API DE PRODUCTOS
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 3: API DE PRODUCTOS (CRUD Completo)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/api/producto" "Listar Productos (GET)" "GET"
if ($r) { $todosLosResultados += $r }

$r = Test-Endpoint "$baseUrl/api/producto" "Crear Producto (POST)" "POST" @{
    Nombre = "Producto Test"
    Descripcion = "Test de rendimiento"
    Precio = 99.99
    Stock = 100
} 20
if ($r) { $todosLosResultados += $r }

# ============================================================
# CATEGORIA 4: API DE SERVICIOS
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 4: API DE SERVICIOS (CRUD Completo)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/api/servicio" "Listar Servicios (GET)" "GET"
if ($r) { $todosLosResultados += $r }

$r = Test-Endpoint "$baseUrl/api/servicio" "Crear Servicio (POST)" "POST" @{
    Nombre = "Servicio Test"
    Descripcion = "Test de rendimiento"
    PrecioBase = 299.99
} 20
if ($r) { $todosLosResultados += $r }

# ============================================================
# CATEGORIA 5: API DE SOLICITUDES
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 5: API DE SOLICITUDES (Flujo Completo)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/api/solicitud" "Listar Todas las Solicitudes" "GET"
if ($r) { $todosLosResultados += $r }

$r = Test-Endpoint "$baseUrl/api/solicitud/pendientes" "Listar Solicitudes Pendientes" "GET"
if ($r) { $todosLosResultados += $r }

# ============================================================
# CATEGORIA 6: API DE FACTURAS
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 6: API DE FACTURAS (Critico)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/api/factura" "Listar Facturas" "GET"
if ($r) { $todosLosResultados += $r }

# ============================================================
# CATEGORIA 7: API DE ABONOS
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 7: API DE ABONOS (Pagos)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Nota: POST de abonos requiere ID de factura válido

# ============================================================
# CATEGORIA 8: API DE EMPLEADOS
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CATEGORIA 8: API DE EMPLEADOS (Gestion)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$r = Test-Endpoint "$baseUrl/api/empleado" "Listar Empleados" "GET"
if ($r) { $todosLosResultados += $r }

# ============================================================
# RESUMEN DE RESULTADOS
# ============================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE RESULTADOS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Mostrar tabla completa
$todosLosResultados | Format-Table -AutoSize -Property Componente, Metodo, TotalRequests, TasaExito, Promedio, Minimo, Maximo, P95, P99

# Análisis por categorías
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "ANALISIS POR RENDIMIENTO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$excelentes = $todosLosResultados | Where-Object { $_.Promedio -lt 100 }
$buenos = $todosLosResultados | Where-Object { $_.Promedio -ge 100 -and $_.Promedio -lt 300 }
$aceptables = $todosLosResultados | Where-Object { $_.Promedio -ge 300 -and $_.Promedio -lt 1000 }
$lentos = $todosLosResultados | Where-Object { $_.Promedio -ge 1000 }

Write-Host "EXCELENTES (< 100ms): $($excelentes.Count) endpoints" -ForegroundColor Green
foreach ($e in $excelentes) {
    Write-Host "  - $($e.Componente): $($e.Promedio) ms" -ForegroundColor Green
}

Write-Host ""
Write-Host "BUENOS (100-300ms): $($buenos.Count) endpoints" -ForegroundColor Yellow
foreach ($b in $buenos) {
    Write-Host "  - $($b.Componente): $($b.Promedio) ms" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "ACEPTABLES (300-1000ms): $($aceptables.Count) endpoints" -ForegroundColor DarkYellow
foreach ($a in $aceptables) {
    Write-Host "  - $($a.Componente): $($a.Promedio) ms [REQUIERE ATENCION]" -ForegroundColor DarkYellow
}

if ($lentos.Count -gt 0) {
    Write-Host ""
    Write-Host "LENTOS (> 1000ms): $($lentos.Count) endpoints [CRITICO]" -ForegroundColor Red
    foreach ($l in $lentos) {
        Write-Host "  - $($l.Componente): $($l.Promedio) ms [OPTIMIZAR URGENTE]" -ForegroundColor Red
    }
}

# Estadísticas globales
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "ESTADISTICAS GLOBALES" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$totalRequests = ($todosLosResultados | Measure-Object -Property TotalRequests -Sum).Sum
$totalExitosos = ($todosLosResultados | Measure-Object -Property Exitosos -Sum).Sum
$totalFallidos = ($todosLosResultados | Measure-Object -Property Fallidos -Sum).Sum
$promedioGeneral = [math]::Round(($todosLosResultados | Measure-Object -Property Promedio -Average).Average, 2)
$tasaExitoGlobal = [math]::Round((($totalExitosos / $totalRequests) * 100), 2)

Write-Host "Total de Requests: $totalRequests" -ForegroundColor White
Write-Host "Requests Exitosos: $totalExitosos" -ForegroundColor Green
Write-Host "Requests Fallidos: $totalFallidos" -ForegroundColor $(if ($totalFallidos -gt 0) { "Red" } else { "Green" })
Write-Host "Tasa de Exito Global: $tasaExitoGlobal%" -ForegroundColor $(if ($tasaExitoGlobal -ge 95) { "Green" } elseif ($tasaExitoGlobal -ge 90) { "Yellow" } else { "Red" })
Write-Host "Promedio General: $promedioGeneral ms" -ForegroundColor $(if ($promedioGeneral -lt 300) { "Green" } elseif ($promedioGeneral -lt 1000) { "Yellow" } else { "Red" })

# Guardar reporte
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "GENERANDO REPORTE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportePath = "reporte-rendimiento-completo_$fecha.txt"
$reporteHtml = "reporte-rendimiento-completo_$fecha.html"

# Reporte TXT
$reporte = @"
============================================================
REPORTE COMPLETO DE PRUEBAS DE RENDIMIENTO
Sistema de Gestion de Taller Mecanico
============================================================
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Servidor: $baseUrl
Configuracion: $RequestsPorEndpoint requests por endpoint, $DelayMs ms delay

RESULTADOS DETALLADOS:
$($todosLosResultados | Format-Table -AutoSize | Out-String)

ESTADISTICAS GLOBALES:
- Total de Requests: $totalRequests
- Requests Exitosos: $totalExitosos
- Requests Fallidos: $totalFallidos
- Tasa de Exito Global: $tasaExitoGlobal%
- Promedio General: $promedioGeneral ms

CATEGORIAS DE RENDIMIENTO:
- Excelentes (< 100ms): $($excelentes.Count) endpoints
- Buenos (100-300ms): $($buenos.Count) endpoints
- Aceptables (300-1000ms): $($aceptables.Count) endpoints
- Lentos (> 1000ms): $($lentos.Count) endpoints

RECOMENDACIONES:
1. $(if ($lentos.Count -gt 0) { "PRIORIDAD ALTA: Optimizar endpoints lentos" } else { "Rendimiento general aceptable" })
2. $(if ($aceptables.Count -gt 3) { "Revisar endpoints aceptables para mejoras" } else { "Pocos endpoints requieren atencion" })
3. $(if ($tasaExitoGlobal -lt 95) { "CRITICO: Tasa de exito baja, revisar errores" } else { "Tasa de exito dentro de parametros" })
4. $(if ($promedioGeneral -gt 500) { "Considerar implementar cache y optimizaciones" } else { "Tiempos de respuesta aceptables" })

ERRORES DETECTADOS:
$($errorLog -join "`n")
"@

$reporte | Out-File -FilePath $reportePath -Encoding UTF8
Write-Host "[OK] Reporte TXT guardado: $reportePath" -ForegroundColor Green

# Reporte HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Rendimiento - $(Get-Date -Format 'yyyy-MM-dd HH:mm')</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-card h3 { margin: 0; font-size: 14px; opacity: 0.9; }
        .stat-card .value { font-size: 32px; font-weight: bold; margin: 10px 0; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #3498db; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f1f1f1; }
        .excelente { color: #27ae60; font-weight: bold; }
        .bueno { color: #f39c12; font-weight: bold; }
        .aceptable { color: #e67e22; font-weight: bold; }
        .lento { color: #e74c3c; font-weight: bold; }
        .success { color: #27ae60; }
        .warning { color: #f39c12; }
        .danger { color: #e74c3c; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Reporte de Pruebas de Rendimiento</h1>
        <p><strong>Fecha:</strong> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <p><strong>Sistema:</strong> Gestion de Taller Mecanico</p>
        <p><strong>Servidor:</strong> $baseUrl</p>
        
        <h2>Estadisticas Globales</h2>
        <div class="stats">
            <div class="stat-card">
                <h3>Total Requests</h3>
                <div class="value">$totalRequests</div>
            </div>
            <div class="stat-card">
                <h3>Tasa de Exito</h3>
                <div class="value">$tasaExitoGlobal%</div>
            </div>
            <div class="stat-card">
                <h3>Promedio General</h3>
                <div class="value">$promedioGeneral ms</div>
            </div>
            <div class="stat-card">
                <h3>Endpoints Probados</h3>
                <div class="value">$($todosLosResultados.Count)</div>
            </div>
        </div>
        
        <h2>Resultados Detallados</h2>
        <table>
            <tr>
                <th>Componente</th>
                <th>Metodo</th>
                <th>Requests</th>
                <th>Tasa Exito</th>
                <th>Promedio (ms)</th>
                <th>Min (ms)</th>
                <th>Max (ms)</th>
                <th>P95 (ms)</th>
                <th>Estado</th>
            </tr>
$(foreach ($r in $todosLosResultados) {
    $clase = if ($r.Promedio -lt 100) { "excelente" }
             elseif ($r.Promedio -lt 300) { "bueno" }
             elseif ($r.Promedio -lt 1000) { "aceptable" }
             else { "lento" }
    $estado = if ($r.Promedio -lt 100) { "EXCELENTE" }
              elseif ($r.Promedio -lt 300) { "BUENO" }
              elseif ($r.Promedio -lt 1000) { "ACEPTABLE" }
              else { "LENTO" }
    @"
            <tr>
                <td>$($r.Componente)</td>
                <td>$($r.Metodo)</td>
                <td>$($r.TotalRequests)</td>
                <td>$($r.TasaExito)</td>
                <td class="$clase">$($r.Promedio)</td>
                <td>$($r.Minimo)</td>
                <td>$($r.Maximo)</td>
                <td>$($r.P95)</td>
                <td class="$clase">$estado</td>
            </tr>
"@
})
        </table>
        
        <h2>Recomendaciones</h2>
        <ul>
            <li class="$(if ($lentos.Count -gt 0) { 'danger' } else { 'success' })">
                $(if ($lentos.Count -gt 0) { "PRIORIDAD ALTA: Optimizar $($lentos.Count) endpoint(s) lento(s)" } else { "Rendimiento general aceptable" })
            </li>
            <li class="$(if ($aceptables.Count -gt 3) { 'warning' } else { 'success' })">
                $(if ($aceptables.Count -gt 3) { "Revisar $($aceptables.Count) endpoint(s) aceptable(s) para mejoras" } else { "Pocos endpoints requieren atencion" })
            </li>
            <li class="$(if ($tasaExitoGlobal -lt 95) { 'danger' } elseif ($tasaExitoGlobal -lt 98) { 'warning' } else { 'success' })">
                $(if ($tasaExitoGlobal -lt 95) { "CRITICO: Tasa de exito baja ($tasaExitoGlobal%), revisar errores" } else { "Tasa de exito dentro de parametros ($tasaExitoGlobal%)" })
            </li>
        </ul>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath $reporteHtml -Encoding UTF8
Write-Host "[OK] Reporte HTML guardado: $reporteHtml" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Abrir reporte
$abrir = Read-Host "Abrir reporte HTML? (S/N)"
if ($abrir -eq "S" -or $abrir -eq "s") {
    Start-Process $reporteHtml
}
