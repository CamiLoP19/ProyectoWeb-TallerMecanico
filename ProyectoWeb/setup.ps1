<#
.SYNOPSIS
  setup.ps1 - Configuración inicial + Medición de INSTALABILIDAD (versión PRO)

.DESCRIPTION
  - Detecta permisos (Admin)
  - Modo no interactivo (para CI)
  - Valida .NET SDK, firebase-credentials.json, appsettings
  - Restaura paquetes, compila
  - Registra métricas, errores, tiempos
  - Genera: install.log, install_report.json, reporte_instalacion.html

.PARAMETER NonInteractive
  Ejecuta en modo no interactivo (no pide Read-Host y no lanza dotnet run al final).

.EXAMPLE
  .\setup.ps1
  .\setup.ps1 -NonInteractive
#>

param(
    [switch]$NonInteractive
)

# ---------------------------
# Configuración inicial
# ---------------------------
$ErrorActionPreference = "Stop"
$scriptStart = Get-Date
$logFile = "install.log"
$jsonReport = "install_report.json"
$htmlReport = "reporte_instalacion.html"

# Inicializar log (sobrescribe)
"" | Out-File -FilePath $logFile -Encoding UTF8

function Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $msg"
    Write-Host $line
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Is-RunningAsAdmin {
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

Log "Inicio del setup.ps1"
Log "Modo NonInteractive: $($NonInteractive.IsPresent)"

# ---------------------------
# Estructuras para métricas
# ---------------------------
$metricas = @()
$errores = @()
$dependencias = @{
    DotNet = $null
    Firebase = $null
    OS = (Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption) -replace "`r`n",""
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
}

function RegistrarPaso {
    param(
        [string]$Nombre,
        [string]$Estado,
        [double]$Tiempo,
        [string]$Detalle = ""
    )
    $script:metricas += [PSCustomObject]@{
        Paso    = $Nombre
        Estado  = $Estado
        Tiempo  = [math]::Round($Tiempo,2)
        Detalle = $Detalle
    }
    $logMsg = "Paso: $Nombre | Estado: $Estado | Tiempo: $([math]::Round($Tiempo,2))s"
    if ($Detalle) { $logMsg += " | Detalle: $Detalle" }
    Log $logMsg

    if ($Estado -ne "Exito") {
        $script:errores += @{
            paso = $Nombre
            mensaje = $Detalle
        }
    }
}

function Medir-Ejecutar {
    param(
        [string]$Nombre,
        [scriptblock]$Accion
    )
    $inicio = Get-Date
    try {
        & $Accion
        $fin = Get-Date
        $dur = ($fin - $inicio).TotalSeconds
        RegistrarPaso -Nombre $Nombre -Estado "Exito" -Tiempo $dur
        return $true
    } catch {
        $fin = Get-Date
        $dur = ($fin - $inicio).TotalSeconds
        $msg = $_.Exception.Message
        RegistrarPaso -Nombre $Nombre -Estado "Fallo" -Tiempo $dur -Detalle $msg
        return $false
    }
}

# ---------------------------
# Chequeo de permisos (Admin)
# ---------------------------
if (-not (Is-RunningAsAdmin)) {
    Log "Advertencia: No se está ejecutando como Administrador. Algunas operaciones pueden fallar."
    if (-not $NonInteractive) {
        $resp = Read-Host "¿Deseas continuar sin permisos de administrador? (S/N)"
        if ($resp -ne "S" -and $resp -ne "s") {
            Log "Usuario canceló por falta de permisos de admin."
            throw "Se requiere ejecutar como Administrador. Cancelling."
        }
    } else {
        Log "Modo non-interactive: continuando sin admin."
    }
} else {
    Log "Ejecución con permisos de Administrador detectada."
}

# ---------------------------
# Banner visual
# ---------------------------
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Configuración Inicial - ProyectoWeb (PRO)" -ForegroundColor Cyan
Write-Host "   ASP.NET Core + Blazor + Firebase" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------
# 1) Verificar .NET SDK
# ---------------------------
$ok = Medir-Ejecutar "Verificar .NET SDK" {
    try {
        $version = & dotnet --version 2>$null
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($version)) { 
            throw "dotnet no accesible" 
        }
        $script:dependencias.DotNet = $version.Trim()
        Write-Host "   OK .NET SDK instalado: $($script:dependencias.DotNet)" -ForegroundColor Green
    } catch {
        $script:dependencias.DotNet = $null
        Write-Host "   X .NET SDK no encontrado" -ForegroundColor Red
        Write-Host "   Instala .NET 8.0 SDK: https://dotnet.microsoft.com/download" -ForegroundColor Red
        throw $_
    }
}

# ---------------------------
# 2) Verificar carpeta del proyecto (ProyectoWeb.csproj)
# ---------------------------
$ok = Medir-Ejecutar "Validar ProyectoWeb.csproj" {
    if (-not (Test-Path "ProyectoWeb.csproj")) {
        throw "ProyectoWeb.csproj no encontrado. Ejecuta el script desde la carpeta del proyecto."
    } else {
        Write-Host "   OK ProyectoWeb.csproj encontrado" -ForegroundColor Green
    }
}

# ---------------------------
# 3) Restaurar paquetes NuGet
# ---------------------------
$ok = Medir-Ejecutar "Restaurar Paquetes NuGet" {
    & dotnet restore
    if ($LASTEXITCODE -ne 0) { throw "dotnet restore retornó código $LASTEXITCODE" }
}

# ---------------------------
# 4) Verificar credenciales de Firebase
# ---------------------------
$ok = Medir-Ejecutar "Verificar firebase-credentials.json" {
    if (Test-Path "firebase-credentials.json") {
        try {
            $contentRaw = Get-Content "firebase-credentials.json" -Raw
            $firebaseContent = $contentRaw | ConvertFrom-Json
            if ($firebaseContent.project_id) {
                $script:dependencias.Firebase = "OK"
                Write-Host "   OK firebase-credentials.json encontrado (Project ID: $($firebaseContent.project_id))" -ForegroundColor Green
            } else {
                $script:dependencias.Firebase = "INVALIDO"
                throw "firebase-credentials.json no contiene project_id válido"
            }
        } catch {
            $script:dependencias.Firebase = "INVALIDO"
            throw $_
        }
    } else {
        $script:dependencias.Firebase = "FALTANTE"
        Write-Host "   ! firebase-credentials.json no encontrado" -ForegroundColor Yellow
        if (-not $NonInteractive) {
            Write-Host ""
            Write-Host "   Pasos para obtener el JSON en Firebase:" -ForegroundColor White
            Write-Host "   1. https://console.firebase.google.com/" -ForegroundColor White
            Write-Host "   2. Proyecto -> Configuración -> Cuentas de servicio" -ForegroundColor White
            Write-Host "   3. Generar clave privada (descargar JSON) y guardarla como firebase-credentials.json" -ForegroundColor White
            Write-Host ""
            $respuesta = Read-Host "¿Ya tienes el archivo firebase-credentials.json? (S/N)"
            if ($respuesta -eq "S" -or $respuesta -eq "s") {
                Write-Host "   Coloca el archivo en esta carpeta y vuelve a ejecutar el script." -ForegroundColor Yellow
                throw "Usuario indicó que colocará firebase-credentials.json luego"
            } else {
                Write-Host "   Creando archivo temporal de ejemplo (NO válido para producción)..." -ForegroundColor Yellow
                $firebaseTemplate = @'
{
  "type": "service_account",
  "project_id": "CONFIGURA_TU_PROJECT_ID",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nTEMPORAL\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk@example.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk"
}
'@
                $firebaseTemplate | Out-File -FilePath "firebase-credentials.json" -Encoding UTF8
                $script:dependencias.Firebase = "TEMPORAL"
                Write-Host "   Archivo temporal creado: firebase-credentials.json" -ForegroundColor Yellow
            }
        } else {
            Log "Modo non-interactive: firebase faltante. Creando temporal."
            $firebaseTemplate = @'
{
  "type": "service_account",
  "project_id": "CONFIGURA_TU_PROJECT_ID",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nTEMPORAL\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk@example.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk"
}
'@
            $firebaseTemplate | Out-File -FilePath "firebase-credentials.json" -Encoding UTF8
            $script:dependencias.Firebase = "TEMPORAL"
        }
    }
}

# ---------------------------
# 5) Configurar appsettings.json y appsettings.Development.json
# ---------------------------
$ok = Medir-Ejecutar "Configurar appsettings.json" {
    if (-not (Test-Path "firebase-credentials.json")) { 
        throw "firebase-credentials.json no disponible para configurar appsettings" 
    }
    $firebaseContent = Get-Content "firebase-credentials.json" -Raw | ConvertFrom-Json
    $projectId = $firebaseContent.project_id

    # appsettings.json
    if (Test-Path "appsettings.json") {
        $appsettings = Get-Content "appsettings.json" -Raw | ConvertFrom-Json
    } else {
        $appsettings = @{ Firebase = @{ ProjectId = ""; CredentialsPath = "" } }
    }
    $appsettings.Firebase.ProjectId = $projectId
    $appsettings.Firebase.CredentialsPath = "firebase-credentials.json"
    $appsettings | ConvertTo-Json -Depth 10 | Set-Content "appsettings.json" -Encoding UTF8

    # appsettings.Development.json
    if (Test-Path "appsettings.Development.json") {
        $appsettingsDev = Get-Content "appsettings.Development.json" -Raw | ConvertFrom-Json
    } else {
        $appsettingsDev = @{ Firebase = @{ ProjectId = ""; CredentialsPath = "" } }
    }
    $appsettingsDev.Firebase.ProjectId = $projectId
    $appsettingsDev.Firebase.CredentialsPath = "firebase-credentials.json"
    $appsettingsDev | ConvertTo-Json -Depth 10 | Set-Content "appsettings.Development.json" -Encoding UTF8

    Write-Host "   OK appsettings.json y appsettings.Development.json configurados" -ForegroundColor Green
}

# ---------------------------
# 6) Compilar proyecto
# ---------------------------
$ok = Medir-Ejecutar "Compilar proyecto (dotnet build)" {
    & dotnet build
    if ($LASTEXITCODE -ne 0) { throw "dotnet build retornó código $LASTEXITCODE" }
}

# ---------------------------
# Resumen final
# ---------------------------
$scriptEnd = Get-Date
$totalTime = ($scriptEnd - $scriptStart).TotalSeconds

# Calcular puntaje de instalabilidad
$maxScore = 100
$score = $maxScore

if (-not $dependencias.DotNet) { $score -= 50 }
switch ($dependencias.Firebase) {
    "OK"       { $score += 0 }
    "TEMPORAL" { $score -= 10 }
    "FALTANTE" { $score -= 20 }
    "INVALIDO" { $score -= 15 }
}

$score -= ($errores.Count * 10)
$fallos = ($metricas | Where-Object { $_.Estado -ne "Exito" }).Count
$score -= ($fallos * 5)

if ($score -gt 100) { $score = 100 }
if ($score -lt 0) { $score = 0 }

# Armar objeto de reporte
$reportObject = [PSCustomObject]@{
    Fecha          = (Get-Date).ToString("o")
    TiempoTotalSeg = [math]::Round($totalTime,2)
    Puntaje        = $score
    Dependencias   = $dependencias
    Errores        = $errores
    Pasos          = $metricas
}

# Guardar JSON
$reportObject | ConvertTo-Json -Depth 10 | Set-Content $jsonReport -Encoding UTF8
Log "Reporte JSON generado: $jsonReport"

# ---------------------------
# Generar HTML
# ---------------------------
$tiempoTotalRounded = [math]::Round($totalTime,2)
$dotnetStatus = if ([string]::IsNullOrEmpty($dependencias.DotNet)) { 
    '<span class="bad">No instalado</span>' 
} else { 
    $dependencias.DotNet 
}

$firebaseStatus = if ($dependencias.Firebase -eq "OK") { 
    '<span class="ok">OK</span>' 
} elseif ($dependencias.Firebase -eq "TEMPORAL") { 
    '<span class="warn">TEMPORAL (ejemplo)</span>' 
} else { 
    "<span class='bad'>$($dependencias.Firebase)</span>" 
}

$html = @"
<!doctype html>
<html lang='es'>
<head>
<meta charset='utf-8'/>
<meta name='viewport' content='width=device-width,initial-scale=1'/>
<title>Reporte de Instalación - ProyectoWeb</title>
<style>
    body { font-family: Inter, Arial, sans-serif; background:#f6f8fb; margin:0; padding:30px; color:#34495e; }
    .container { max-width:1000px; margin:0 auto; }
    .card { background:#ffffff; border-radius:12px; padding:20px; box-shadow: 0 6px 18px rgba(50,50,93,0.08); margin-bottom:18px; }
    h1 { margin:0; color:#2b6cb0; }
    h2 { color:#2b6cb0; }
    .meta { color:#6b7280; margin-top:8px; }
    .kpi { display:flex; gap:12px; margin-top:12px; }
    .kpi .box { flex:1; background:#f3f7fb; border-radius:10px; padding:12px; text-align:center; }
    .kpi .big { font-size:22px; font-weight:700; color:#0f172a; }
    table { width:100%; border-collapse:collapse; margin-top:12px; }
    th { text-align:left; padding:10px; background:#2b6cb0; color:white; }
    td { padding:10px; border-bottom:1px solid #eef2f7; background:#fcfeff; }
    .ok { color:#16a34a; font-weight:700; }
    .bad { color:#dc2626; font-weight:700; }
    .warn { color:#d97706; font-weight:700; }
    .small { color:#6b7280; font-size:13px; }
    .footer { text-align:center; color:#94a3b8; font-size:13px; margin-top:16px; }
</style>
</head>
<body>
<div class='container'>
    <div class='card'>
        <h1>Reporte de Instalación - ProyectoWeb</h1>
        <div class='meta'>Generado: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - Tiempo total: $tiempoTotalRounded segundos</div>
        <div class='kpi'>
            <div class='box'>
                <div class='small'>INSTALABILIDAD</div>
                <div class='big'>$score / 100</div>
            </div>
            <div class='box'>
                <div class='small'>Errores detectados</div>
                <div class='big'>$($errores.Count)</div>
            </div>
            <div class='box'>
                <div class='small'>Pasos totales</div>
                <div class='big'>$($metricas.Count)</div>
            </div>
        </div>
    </div>

    <div class='card'>
        <h2>Dependencias</h2>
        <table>
            <tr><th>Componente</th><th>Estado / Detalle</th></tr>
            <tr><td>.NET SDK</td><td>$dotnetStatus</td></tr>
            <tr><td>Firebase Credentials</td><td>$firebaseStatus</td></tr>
        </table>
    </div>

    <div class='card'>
        <h2>Detalle por paso</h2>
        <table>
            <tr><th>Paso</th><th>Tiempo (s)</th><th>Estado</th><th>Detalle</th></tr>
"@

foreach ($p in $metricas) {
    $estadoHtml = if ($p.Estado -eq "Exito") { 
        "<span class='ok'>OK Exito</span>" 
    } elseif ($p.Estado -eq "Fallo") { 
        "<span class='bad'>X Fallo</span>" 
    } else { 
        "<span class='small'>$($p.Estado)</span>" 
    }
    $detalle = if ($p.Detalle) { 
        [System.Web.HttpUtility]::HtmlEncode($p.Detalle) 
    } else { 
        "" 
    }
    $html += "            <tr><td>$($p.Paso)</td><td>$($p.Tiempo)</td><td>$estadoHtml</td><td class='small'>$detalle</td></tr>`n"
}

$html += @"
        </table>
    </div>

    <div class='card'>
        <h2>Errores</h2>
"@

if ($errores.Count -eq 0) {
    $html += "        <p class='small'>No se detectaron errores.</p>`n"
} else {
    $html += "        <ul class='small'>`n"
    foreach ($e in $errores) {
        $mensaje = [System.Web.HttpUtility]::HtmlEncode($e.mensaje)
        $html += "            <li><strong>$($e.paso):</strong> $mensaje</li>`n"
    }
    $html += "        </ul>`n"
}

$html += @"
    </div>

    <div class='footer'>
        Este informe fue generado por el script de configuración. Revisa $jsonReport y $logFile para detalles técnicos.
    </div>

</div>
</body>
</html>
"@

$html | Set-Content -Path $htmlReport -Encoding UTF8
Log "Reporte HTML generado: $htmlReport"

# Mensajes finales
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Configuración Finalizada" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Reportes generados:" -ForegroundColor White
Write-Host " - $jsonReport" -ForegroundColor Yellow
Write-Host " - $htmlReport" -ForegroundColor Yellow
Write-Host " - $logFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "Puntaje de INSTALABILIDAD: $score / 100" -ForegroundColor Cyan
Write-Host ""

if (-not $NonInteractive) {
    try {
        $ejecutar = Read-Host "¿Deseas ejecutar la aplicación ahora? (S/N)"
        if ($ejecutar -eq "S" -or $ejecutar -eq "s") {
            Write-Host ""
            Write-Host "Iniciando aplicación..." -ForegroundColor Green
            Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
            Write-Host ""
            & dotnet run
        } else {
            Write-Host "Proceso finalizado. No se inició la aplicación." -ForegroundColor Yellow
        }
    } catch {
        Log "Error al intentar ejecutar la aplicación: $($_.Exception.Message)"
    }
} else {
    Log "Modo non-interactive: no se lanza dotnet run."
}

Log "Fin del setup.ps1"