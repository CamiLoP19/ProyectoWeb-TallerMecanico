<#
.SYNOPSIS
  measure-quality.ps1 - Medicion de PORTABILIDAD (Reemplazabilidad, Coexistencia, Interoperabilidad)

.DESCRIPTION
  Analiza el proyecto ProyectoWeb para medir:
  - REEMPLAZABILIDAD: Facilidad para reemplazar componentes
  - COEXISTENCIA: Capacidad de coexistir con otros sistemas
  - INTEROPERABILIDAD: Capacidad de intercambiar informacion

.EXAMPLE
  .\measure-quality.ps1
#>

param()

$ErrorActionPreference = "Continue"
$scriptStart = Get-Date
$logFile = "quality_measure.log"
$jsonReport = "quality_report.json"
$htmlReport = "reporte_portabilidad.html"

# Inicializar log
"" | Out-File -FilePath $logFile -Encoding UTF8

function Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $msg"
    Write-Host $line
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Log "=== INICIO: Medicion de Portabilidad ==="

# Estructuras de metricas
$metricas = @{
    Reemplazabilidad = @{
        Puntaje = 0
        Detalles = @()
    }
    Coexistencia = @{
        Puntaje = 0
        Detalles = @()
    }
    Interoperabilidad = @{
        Puntaje = 0
        Detalles = @()
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   MEDICION DE PORTABILIDAD - ProyectoWeb" -ForegroundColor Cyan
Write-Host "   Reemplazabilidad | Coexistencia | Interoperabilidad" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# =================================================================
# 1. REEMPLAZABILIDAD
# =================================================================
Write-Host "1. Analizando REEMPLAZABILIDAD..." -ForegroundColor Yellow
$reemplazabilidadInicio = Get-Date

$puntajeReemplazabilidad = 100
$detallesReemplazabilidad = @()

# 1.1 Verificar uso de Inyeccion de Dependencias
Log "  1.1 Verificando inyeccion de dependencias..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    $serviciosRegistrados = ([regex]::Matches($programContent, "AddScoped<(\w+)>")).Count
    $serviciosSingleton = ([regex]::Matches($programContent, "AddSingleton")).Count
    
    if ($serviciosRegistrados -gt 0) {
        $detallesReemplazabilidad += "OK: $serviciosRegistrados servicios registrados con DI (Dependency Injection)"
        Log "    OK $serviciosRegistrados servicios con DI detectados"
    } else {
        $puntajeReemplazabilidad -= 30
        $detallesReemplazabilidad += "FALLO: No se detecto uso de inyeccion de dependencias"
        Log "    X No se detecto DI"
    }
}

# 1.2 Verificar uso de interfaces
Log "  1.2 Verificando uso de interfaces..."
$interfacesEncontradas = 0
if (Test-Path "Services") {
    $servicios = Get-ChildItem -Path "Services" -Filter "*.cs" -Recurse
    foreach ($servicio in $servicios) {
        $content = Get-Content $servicio.FullName -Raw
        if ($content -match "interface\s+I\w+") {
            $interfacesEncontradas++
        }
    }
}

if ($interfacesEncontradas -gt 5) {
    $detallesReemplazabilidad += "EXCELENTE: $interfacesEncontradas interfaces encontradas (alta abstraccion)"
    Log "    OK $interfacesEncontradas interfaces detectadas"
} elseif ($interfacesEncontradas -gt 0) {
    $puntajeReemplazabilidad -= 10
    $detallesReemplazabilidad += "PARCIAL: Solo $interfacesEncontradas interfaces (se recomienda mas abstraccion)"
    Log "    ! Solo $interfacesEncontradas interfaces"
} else {
    $puntajeReemplazabilidad -= 25
    $detallesReemplazabilidad += "FALLO: No se encontraron interfaces. Se recomienda usar IService para cada servicio"
    Log "    X No se encontraron interfaces"
}

# 1.3 Verificar configuracion externalizada
Log "  1.3 Verificando configuracion externalizada..."
$archivosConfig = @("appsettings.json", "appsettings.Development.json", "appsettings.Local.json")
$configEncontrados = 0
foreach ($config in $archivosConfig) {
    if (Test-Path $config) {
        $configEncontrados++
    }
}

if ($configEncontrados -ge 2) {
    $detallesReemplazabilidad += "OK: Configuracion externalizada en multiples archivos ($configEncontrados encontrados)"
    Log "    OK $configEncontrados archivos de configuracion"
} else {
    $puntajeReemplazabilidad -= 15
    $detallesReemplazabilidad += "PARCIAL: Poca configuracion externalizada"
    Log "    ! Solo $configEncontrados archivo(s) de configuracion"
}

# 1.4 Verificar dependencias externas
Log "  1.4 Analizando dependencias externas..."
if (Test-Path "ProyectoWeb.csproj") {
    $csprojContent = Get-Content "ProyectoWeb.csproj" -Raw
    $packageReferences = ([regex]::Matches($csprojContent, "<PackageReference")).Count
    
    if ($packageReferences -lt 15) {
        $detallesReemplazabilidad += "OK: $packageReferences dependencias NuGet (bajo acoplamiento externo)"
        Log "    OK $packageReferences dependencias NuGet"
    } elseif ($packageReferences -lt 25) {
        $puntajeReemplazabilidad -= 5
        $detallesReemplazabilidad += "ACEPTABLE: $packageReferences dependencias NuGet (moderado)"
        Log "    ! $packageReferences dependencias NuGet (moderado)"
    } else {
        $puntajeReemplazabilidad -= 10
        $detallesReemplazabilidad += "ALTO: $packageReferences dependencias NuGet (alto acoplamiento)"
        Log "    ! $packageReferences dependencias NuGet (alto)"
    }
}

# 1.5 Verificar patron Repository/Service
Log "  1.5 Verificando patron Service..."
if (Test-Path "Services") {
    $cantidadServicios = (Get-ChildItem -Path "Services" -Filter "*Service.cs").Count
    if ($cantidadServicios -gt 5) {
        $detallesReemplazabilidad += "OK: $cantidadServicios servicios implementados (buen patron de separacion)"
        Log "    OK $cantidadServicios servicios encontrados"
    }
}

$tiempoReemplazabilidad = ((Get-Date) - $reemplazabilidadInicio).TotalSeconds
$metricas.Reemplazabilidad.Puntaje = [math]::Max(0, $puntajeReemplazabilidad)
$metricas.Reemplazabilidad.Detalles = $detallesReemplazabilidad
Log "  REEMPLAZABILIDAD: $($metricas.Reemplazabilidad.Puntaje)/100 (tiempo: $([math]::Round($tiempoReemplazabilidad,2))s)"
Write-Host "  Puntaje: $($metricas.Reemplazabilidad.Puntaje)/100" -ForegroundColor $(if($metricas.Reemplazabilidad.Puntaje -ge 80){"Green"}elseif($metricas.Reemplazabilidad.Puntaje -ge 60){"Yellow"}else{"Red"})

# =================================================================
# 2. COEXISTENCIA
# =================================================================
Write-Host ""
Write-Host "2. Analizando COEXISTENCIA..." -ForegroundColor Yellow
$coexistenciaInicio = Get-Date

$puntajeCoexistencia = 100
$detallesCoexistencia = @()

# 2.1 Verificar puertos configurables
Log "  2.1 Verificando puertos configurables..."
$puertoConfigurable = $false
if (Test-Path "appsettings.json") {
    $appsettings = Get-Content "appsettings.json" -Raw
    if ($appsettings -match '"Urls"' -or $appsettings -match '"ApplicationUrl"') {
        $puertoConfigurable = $true
        $detallesCoexistencia += "OK: Puerto configurable en appsettings.json"
        Log "    OK Puerto configurable"
    }
}

if (Test-Path "Properties/launchSettings.json") {
    $launchSettings = Get-Content "Properties/launchSettings.json" -Raw
    $puertosEncontrados = ([regex]::Matches($launchSettings, '"applicationUrl":\s*"https?://[^"]*:(\d+)"')).Count
    if ($puertosEncontrados -gt 0) {
        $detallesCoexistencia += "OK: $puertosEncontrados perfiles de ejecucion con puertos definidos"
        Log "    OK $puertosEncontrados perfiles con puertos"
    }
}

if (-not $puertoConfigurable) {
    $puntajeCoexistencia -= 15
    $detallesCoexistencia += "ADVERTENCIA: No se encontro configuracion explicita de puertos"
    Log "    ! Puerto no explicitamente configurable"
}

# 2.2 Verificar uso de nombres unicos (cookies, rutas)
Log "  2.2 Verificando nombres unicos de recursos..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match 'Cookie\.Name\s*=\s*"([^"]+)"') {
        $cookieName = $matches[1]
        $detallesCoexistencia += "OK: Cookie con nombre unico: '$cookieName'"
        Log "    OK Cookie con nombre unico: $cookieName"
    } else {
        $puntajeCoexistencia -= 10
        $detallesCoexistencia += "ADVERTENCIA: Cookie sin nombre personalizado"
        Log "    ! Cookie sin nombre personalizado"
    }
}

# 2.3 Verificar HTTPS habilitado
Log "  2.3 Verificando HTTPS..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "UseHttpsRedirection") {
        $detallesCoexistencia += "OK: HTTPS Redirection habilitado (seguridad y estandar)"
        Log "    OK HTTPS Redirection habilitado"
    } else {
        $puntajeCoexistencia -= 20
        $detallesCoexistencia += "FALLO: HTTPS no habilitado"
        Log "    X HTTPS no habilitado"
    }
}

# 2.4 Verificar archivos estaticos separados
Log "  2.4 Verificando recursos estaticos..."
if (Test-Path "wwwroot") {
    $archivosEstaticos = (Get-ChildItem -Path "wwwroot" -Recurse -File).Count
    if ($archivosEstaticos -gt 0) {
        $detallesCoexistencia += "OK: $archivosEstaticos archivos estaticos en wwwroot (separacion correcta)"
        Log "    OK $archivosEstaticos archivos estaticos"
    }
}

# 2.5 Verificar logging configurado
Log "  2.5 Verificando logging..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "AddLogging") {
        $detallesCoexistencia += "OK: Sistema de logging configurado"
        Log "    OK Logging configurado"
    } else {
        $puntajeCoexistencia -= 5
        $detallesCoexistencia += "ADVERTENCIA: No se detecto configuracion de logging"
        Log "    ! Logging no detectado"
    }
}

$tiempoCoexistencia = ((Get-Date) - $coexistenciaInicio).TotalSeconds
$metricas.Coexistencia.Puntaje = [math]::Max(0, $puntajeCoexistencia)
$metricas.Coexistencia.Detalles = $detallesCoexistencia
Log "  COEXISTENCIA: $($metricas.Coexistencia.Puntaje)/100 (tiempo: $([math]::Round($tiempoCoexistencia,2))s)"
Write-Host "  Puntaje: $($metricas.Coexistencia.Puntaje)/100" -ForegroundColor $(if($metricas.Coexistencia.Puntaje -ge 80){"Green"}elseif($metricas.Coexistencia.Puntaje -ge 60){"Yellow"}else{"Red"})

# =================================================================
# 3. INTEROPERABILIDAD
# =================================================================
Write-Host ""
Write-Host "3. Analizando INTEROPERABILIDAD..." -ForegroundColor Yellow
$interoperabilidadInicio = Get-Date

$puntajeInteroperabilidad = 100
$detallesInteroperabilidad = @()

# 3.1 Verificar Controllers (API REST)
Log "  3.1 Verificando API REST..."
$controllersEncontrados = 0
$endpointsTotal = 0
if (Test-Path "Controllers") {
    $controllers = Get-ChildItem -Path "Controllers" -Filter "*Controller.cs"
    $controllersEncontrados = $controllers.Count
    
    foreach ($controller in $controllers) {
        $content = Get-Content $controller.FullName -Raw
        $endpoints = ([regex]::Matches($content, "\[Http(Get|Post|Put|Delete|Patch)\]")).Count
        $endpointsTotal += $endpoints
    }
    
    if ($controllersEncontrados -gt 0) {
        $detallesInteroperabilidad += "EXCELENTE: $controllersEncontrados Controllers con $endpointsTotal endpoints REST"
        Log "    OK $controllersEncontrados Controllers, $endpointsTotal endpoints"
    } else {
        $puntajeInteroperabilidad -= 40
        $detallesInteroperabilidad += "FALLO: No se encontraron Controllers REST"
        Log "    X No se encontraron Controllers"
    }
}

# 3.2 Verificar formato JSON
Log "  3.2 Verificando formato JSON..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "AddJsonOptions") {
        $detallesInteroperabilidad += "OK: Serializacion JSON configurada (formato estandar)"
        Log "    OK JSON configurado"
    } else {
        $puntajeInteroperabilidad -= 10
        $detallesInteroperabilidad += "PARCIAL: JSON sin configuracion explicita"
        Log "    ! JSON sin config explicita"
    }
}

# 3.3 Verificar validaciones automaticas (OpenAPI/Swagger implicito)
Log "  3.3 Verificando validaciones automaticas..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "ConfigureApiBehaviorOptions") {
        $detallesInteroperabilidad += "OK: Validaciones automaticas de API configuradas"
        Log "    OK Validaciones automaticas"
    }
    
    # Buscar Swagger
    if ($programContent -match "AddSwagger" -or $programContent -match "UseSwagger") {
        $detallesInteroperabilidad += "EXCELENTE: Swagger/OpenAPI configurado (documentacion automatica)"
        Log "    OK Swagger detectado"
    } else {
        $puntajeInteroperabilidad -= 15
        $detallesInteroperabilidad += "RECOMENDACION: Agregar Swagger para documentacion de API"
        Log "    ! Swagger no detectado"
    }
}

# 3.4 Verificar integraciones externas
Log "  3.4 Verificando integraciones externas..."
$integraciones = @()
if (Test-Path "Services") {
    $servicios = Get-ChildItem -Path "Services" -Filter "*.cs"
    foreach ($servicio in $servicios) {
        $nombre = $servicio.BaseName
        if ($nombre -match "(Firebase|Stripe|Email|Payment)") {
            $integraciones += $nombre
        }
    }
}

if ($integraciones.Count -gt 0) {
    $detallesInteroperabilidad += "EXCELENTE: $($integraciones.Count) integraciones externas detectadas: $($integraciones -join ', ')"
    Log "    OK $($integraciones.Count) integraciones: $($integraciones -join ', ')"
} else {
    $puntajeInteroperabilidad -= 20
    $detallesInteroperabilidad += "FALLO: No se detectaron integraciones externas"
    Log "    X Sin integraciones externas"
}

# 3.5 Verificar autenticacion estandar
Log "  3.5 Verificando autenticacion..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "AddAuthentication") {
        $tipoAuth = "Cookie"
        if ($programContent -match "AddJwtBearer") { $tipoAuth = "JWT" }
        $detallesInteroperabilidad += "OK: Autenticacion configurada ($tipoAuth)"
        Log "    OK Autenticacion: $tipoAuth"
    } else {
        $puntajeInteroperabilidad -= 15
        $detallesInteroperabilidad += "FALLO: No se detecto autenticacion configurada"
        Log "    X Sin autenticacion"
    }
}

# 3.6 Verificar CORS (si aplica)
Log "  3.6 Verificando CORS..."
if (Test-Path "Program.cs") {
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "AddCors") {
        $detallesInteroperabilidad += "OK: CORS configurado (interoperabilidad con frontends externos)"
        Log "    OK CORS configurado"
    } else {
        $detallesInteroperabilidad += "INFO: CORS no detectado (puede no ser necesario para Blazor Server)"
        Log "    i CORS no detectado (puede ser innecesario)"
    }
}

$tiempoInteroperabilidad = ((Get-Date) - $interoperabilidadInicio).TotalSeconds
$metricas.Interoperabilidad.Puntaje = [math]::Max(0, $puntajeInteroperabilidad)
$metricas.Interoperabilidad.Detalles = $detallesInteroperabilidad
Log "  INTEROPERABILIDAD: $($metricas.Interoperabilidad.Puntaje)/100 (tiempo: $([math]::Round($tiempoInteroperabilidad,2))s)"
Write-Host "  Puntaje: $($metricas.Interoperabilidad.Puntaje)/100" -ForegroundColor $(if($metricas.Interoperabilidad.Puntaje -ge 80){"Green"}elseif($metricas.Interoperabilidad.Puntaje -ge 60){"Yellow"}else{"Red"})

# =================================================================
# RESUMEN FINAL
# =================================================================
$scriptEnd = Get-Date
$totalTime = ($scriptEnd - $scriptStart).TotalSeconds

$promedioPortabilidad = [math]::Round(
    ($metricas.Reemplazabilidad.Puntaje + $metricas.Coexistencia.Puntaje + $metricas.Interoperabilidad.Puntaje) / 3, 2
)

# Crear objeto de reporte
$reportObject = [PSCustomObject]@{
    Fecha = (Get-Date).ToString("o")
    TiempoTotal = [math]::Round($totalTime, 2)
    PuntajePromedio = $promedioPortabilidad
    Metricas = @{
        Reemplazabilidad = @{
            Puntaje = $metricas.Reemplazabilidad.Puntaje
            Detalles = $metricas.Reemplazabilidad.Detalles
        }
        Coexistencia = @{
            Puntaje = $metricas.Coexistencia.Puntaje
            Detalles = $metricas.Coexistencia.Detalles
        }
        Interoperabilidad = @{
            Puntaje = $metricas.Interoperabilidad.Puntaje
            Detalles = $metricas.Interoperabilidad.Detalles
        }
    }
}

# Guardar JSON
$reportObject | ConvertTo-Json -Depth 10 | Set-Content $jsonReport -Encoding UTF8
Log "Reporte JSON generado: $jsonReport"

# =================================================================
# GENERAR HTML
# =================================================================
$colorReemplazabilidad = if ($metricas.Reemplazabilidad.Puntaje -ge 80) { "#16a34a" } elseif ($metricas.Reemplazabilidad.Puntaje -ge 60) { "#d97706" } else { "#dc2626" }
$colorCoexistencia = if ($metricas.Coexistencia.Puntaje -ge 80) { "#16a34a" } elseif ($metricas.Coexistencia.Puntaje -ge 60) { "#d97706" } else { "#dc2626" }
$colorInteroperabilidad = if ($metricas.Interoperabilidad.Puntaje -ge 80) { "#16a34a" } elseif ($metricas.Interoperabilidad.Puntaje -ge 60) { "#d97706" } else { "#dc2626" }
$colorPromedio = if ($promedioPortabilidad -ge 80) { "#16a34a" } elseif ($promedioPortabilidad -ge 60) { "#d97706" } else { "#dc2626" }

$fechaFormato = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$tiempoRounded = [math]::Round($totalTime,2)

# Cargar el assembly para HtmlEncode
Add-Type -AssemblyName System.Web

$html = @"
<!doctype html>
<html lang='es'>
<head>
<meta charset='utf-8'/>
<meta name='viewport' content='width=device-width,initial-scale=1'/>
<title>Reporte de Portabilidad - ProyectoWeb</title>
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 30px; }
    .container { max-width: 1100px; margin: 0 auto; }
    .header { background: white; border-radius: 16px; padding: 30px; margin-bottom: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
    .header h1 { color: #1e293b; font-size: 32px; margin-bottom: 8px; }
    .header .meta { color: #64748b; font-size: 14px; }
    .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px; }
    .kpi { background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border-radius: 12px; padding: 20px; text-align: center; }
    .kpi-label { font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600; margin-bottom: 8px; }
    .kpi-value { font-size: 36px; font-weight: 700; }
    .card { background: white; border-radius: 16px; padding: 25px; margin-bottom: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
    .card h2 { color: #1e293b; font-size: 24px; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
    .score { display: inline-block; padding: 8px 16px; border-radius: 20px; color: white; font-weight: 700; font-size: 18px; }
    .detail-list { list-style: none; }
    .detail-list li { padding: 12px; margin: 8px 0; background: #f8fafc; border-left: 4px solid #cbd5e1; border-radius: 6px; font-size: 14px; }
    .detail-list li.ok { border-left-color: #16a34a; background: #f0fdf4; }
    .detail-list li.warn { border-left-color: #d97706; background: #fffbeb; }
    .detail-list li.fail { border-left-color: #dc2626; background: #fef2f2; }
    .detail-list li.info { border-left-color: #3b82f6; background: #eff6ff; }
    .footer { text-align: center; color: white; font-size: 13px; margin-top: 20px; opacity: 0.9; }
    .icon { font-size: 24px; }
    table { width: 100%; border-collapse: collapse; }
    th { padding: 12px; text-align: left; border-bottom: 2px solid #e2e8f0; background: #f8fafc; }
    td { padding: 12px; border-bottom: 1px solid #f1f5f9; }
</style>
</head>
<body>
<div class='container'>
    <div class='header'>
        <h1>Reporte de Portabilidad</h1>
        <div class='meta'>ProyectoWeb - Generado: $fechaFormato - Tiempo: ${tiempoRounded}s</div>
        <div class='kpi-grid'>
            <div class='kpi'>
                <div class='kpi-label'>Promedio General</div>
                <div class='kpi-value' style='color: $colorPromedio'>$promedioPortabilidad</div>
            </div>
            <div class='kpi'>
                <div class='kpi-label'>Reemplazabilidad</div>
                <div class='kpi-value' style='color: $colorReemplazabilidad'>$($metricas.Reemplazabilidad.Puntaje)</div>
            </div>
            <div class='kpi'>
                <div class='kpi-label'>Coexistencia</div>
                <div class='kpi-value' style='color: $colorCoexistencia'>$($metricas.Coexistencia.Puntaje)</div>
            </div>
            <div class='kpi'>
                <div class='kpi-label'>Interoperabilidad</div>
                <div class='kpi-value' style='color: $colorInteroperabilidad'>$($metricas.Interoperabilidad.Puntaje)</div>
            </div>
        </div>
    </div>

    <div class='card'>
        <h2><span class='icon'>🔄</span> Reemplazabilidad <span class='score' style='background: $colorReemplazabilidad'>$($metricas.Reemplazabilidad.Puntaje)/100</span></h2>
        <p style='color: #64748b; margin-bottom: 15px;'>Facilidad para reemplazar componentes del sistema sin afectar su funcionamiento.</p>
        <ul class='detail-list'>
"@

foreach ($detalle in $metricas.Reemplazabilidad.Detalles) {
    $clase = "info"
    if ($detalle -match "^OK:") { $clase = "ok" }
    elseif ($detalle -match "^EXCELENTE:") { $clase = "ok" }
    elseif ($detalle -match "^ADVERTENCIA:") { $clase = "warn" }
    elseif ($detalle -match "^FALLO:") { $clase = "fail" }
    elseif ($detalle -match "^PARCIAL:") { $clase = "warn" }
    elseif ($detalle -match "^ACEPTABLE:") { $clase = "warn" }
    elseif ($detalle -match "^ALTO:") { $clase = "warn" }
    $detalleHtml = [System.Web.HttpUtility]::HtmlEncode($detalle)
    $html += "            <li class='$clase'>$detalleHtml</li>`n"
}

$html += @"
        </ul>
    </div>

    <div class='card'>
        <h2><span class='icon'>🤝</span> Coexistencia <span class='score' style='background: $colorCoexistencia'>$($metricas.Coexistencia.Puntaje)/100</span></h2>
        <p style='color: #64748b; margin-bottom: 15px;'>Capacidad de coexistir con otros sistemas en el mismo entorno sin conflictos.</p>
        <ul class='detail-list'>
"@

foreach ($detalle in $metricas.Coexistencia.Detalles) {
    $clase = "info"
    if ($detalle -match "^OK:") { $clase = "ok" }
    elseif ($detalle -match "^EXCELENTE:") { $clase = "ok" }
    elseif ($detalle -match "^ADVERTENCIA:") { $clase = "warn" }
    elseif ($detalle -match "^FALLO:") { $clase = "fail" }
    elseif ($detalle -match "^INFO:") { $clase = "info" }
    $detalleHtml = [System.Web.HttpUtility]::HtmlEncode($detalle)
    $html += "            <li class='$clase'>$detalleHtml</li>`n"
}

$html += @"
        </ul>
    </div>

    <div class='card'>
        <h2><span class='icon'>🔗</span> Interoperabilidad <span class='score' style='background: $colorInteroperabilidad'>$($metricas.Interoperabilidad.Puntaje)/100</span></h2>
        <p style='color: #64748b; margin-bottom: 15px;'>Capacidad de intercambiar informacion con otros sistemas y aplicaciones.</p>
        <ul class='detail-list'>
"@

foreach ($detalle in $metricas.Interoperabilidad.Detalles) {
    $clase = "info"
    if ($detalle -match "^OK:") { $clase = "ok" }
    elseif ($detalle -match "^EXCELENTE:") { $clase = "ok" }
    elseif ($detalle -match "^ADVERTENCIA:") { $clase = "warn" }
    elseif ($detalle -match "^FALLO:") { $clase = "fail" }
    elseif ($detalle -match "^RECOMENDACION:") { $clase = "warn" }
    elseif ($detalle -match "^PARCIAL:") { $clase = "warn" }
    elseif ($detalle -match "^INFO:") { $clase = "info" }
    $detalleHtml = [System.Web.HttpUtility]::HtmlEncode($detalle)
    $html += "            <li class='$clase'>$detalleHtml</li>`n"
}

$html += @"
        </ul>
    </div>

    <div class='card'>
        <h2><span class='icon'>💡</span> Recomendaciones</h2>
        <ul class='detail-list'>
"@

# Generar recomendaciones basadas en puntajes
if ($metricas.Reemplazabilidad.Puntaje -lt 80) {
    $html += "            <li class='warn'>Implementar interfaces para todos los servicios (IAuthService, IEmpleadoService, etc.)</li>`n"
    $html += "            <li class='warn'>Aumentar el uso de abstracciones para reducir acoplamiento</li>`n"
}
if ($metricas.Coexistencia.Puntaje -lt 80) {
    $html += "            <li class='warn'>Asegurar que todos los recursos (puertos, cookies, rutas) sean configurables</li>`n"
}
if ($metricas.Interoperabilidad.Puntaje -lt 80) {
    $html += "            <li class='warn'>Agregar Swagger/OpenAPI para documentar la API REST automaticamente</li>`n"
    $html += "            <li class='info'>Considerar implementar versionado de API (v1, v2)</li>`n"
}
if ($promedioPortabilidad -ge 80) {
    $html += "            <li class='ok'>¡Excelente trabajo! El proyecto tiene alta portabilidad</li>`n"
}

$html += @"
        </ul>
    </div>

    <div class='card'>
        <h2><span class='icon'>📊</span> Interpretacion de Puntajes</h2>
        <table>
            <tr>
                <th>Rango</th>
                <th>Calificacion</th>
                <th>Descripcion</th>
            </tr>
            <tr>
                <td><strong style='color: #16a34a;'>90-100</strong></td>
                <td>Excelente</td>
                <td>Cumple con las mejores practicas</td>
            </tr>
            <tr>
                <td><strong style='color: #16a34a;'>80-89</strong></td>
                <td>Muy Bueno</td>
                <td>Buena portabilidad con mejoras menores</td>
            </tr>
            <tr>
                <td><strong style='color: #d97706;'>60-79</strong></td>
                <td>Aceptable</td>
                <td>Requiere mejoras moderadas</td>
            </tr>
            <tr>
                <td><strong style='color: #dc2626;'>0-59</strong></td>
                <td>Necesita Mejora</td>
                <td>Requiere atencion inmediata</td>
            </tr>
        </table>
    </div>

    <div class='footer'>
        <p>Este reporte fue generado automaticamente por measure-quality.ps1</p>
        <p>Consulta $jsonReport y $logFile para mas detalles tecnicos</p>
    </div>
</div>
</body>
</html>
"@

$html | Set-Content -Path $htmlReport -Encoding UTF8
Log "Reporte HTML generado: $htmlReport"

# =================================================================
# MOSTRAR RESUMEN EN CONSOLA
# =================================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   MEDICION COMPLETADA" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "RESULTADOS:" -ForegroundColor White
Write-Host ""
Write-Host "  PROMEDIO GENERAL: " -NoNewline
Write-Host "$promedioPortabilidad / 100" -ForegroundColor $(if($promedioPortabilidad -ge 80){"Green"}elseif($promedioPortabilidad -ge 60){"Yellow"}else{"Red"})
Write-Host ""
Write-Host "  REEMPLAZABILIDAD: " -NoNewline
Write-Host "$($metricas.Reemplazabilidad.Puntaje) / 100" -ForegroundColor $(if($metricas.Reemplazabilidad.Puntaje -ge 80){"Green"}elseif($metricas.Reemplazabilidad.Puntaje -ge 60){"Yellow"}else{"Red"})
Write-Host "  COEXISTENCIA: " -NoNewline
Write-Host "$($metricas.Coexistencia.Puntaje) / 100" -ForegroundColor $(if($metricas.Coexistencia.Puntaje -ge 80){"Green"}elseif($metricas.Coexistencia.Puntaje -ge 60){"Yellow"}else{"Red"})
Write-Host "  INTEROPERABILIDAD: " -NoNewline
Write-Host "$($metricas.Interoperabilidad.Puntaje) / 100" -ForegroundColor $(if($metricas.Interoperabilidad.Puntaje -ge 80){"Green"}elseif($metricas.Interoperabilidad.Puntaje -ge 60){"Yellow"}else{"Red"})
Write-Host ""
Write-Host "ARCHIVOS GENERADOS:" -ForegroundColor White
Write-Host "  - $htmlReport" -ForegroundColor Yellow
Write-Host "  - $jsonReport" -ForegroundColor Yellow
Write-Host "  - $logFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "Abre $htmlReport en tu navegador para ver el reporte completo." -ForegroundColor Cyan
Write-Host ""

# Ofrecer abrir el HTML automaticamente
try {
    $abrir = Read-Host "¿Deseas abrir el reporte HTML ahora? (S/N)"
    if ($abrir -eq "S" -or $abrir -eq "s") {
        Start-Process $htmlReport
    }
} catch {
    Log "No se pudo preguntar sobre abrir HTML (modo no interactivo?)"
}

Log "=== FIN: Medicion de Portabilidad ==="
