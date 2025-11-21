# Script de Pruebas Completas - API Taller Mecánico
# Ejecuta todos los endpoints y registra resultados detallados

$baseUrl = "http://localhost:5000"
$logFile = "resultados_pruebas.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Limpiar archivo de log anterior
"=" * 80 | Out-File $logFile
"PRUEBAS API TALLER MECÁNICO - $timestamp" | Out-File $logFile -Append
"=" * 80 | Out-File $logFile -Append
"" | Out-File $logFile -Append

# Variables globales para IDs
$global:clienteId = ""
$global:empleadoId = ""
$global:productoId = ""
$global:solicitudId = ""
$global:facturaId = ""

function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Method,
        [string]$Url,
        [string]$Body,
        [object]$Response,
        [int]$StatusCode,
        [string]$ErrorMsg
    )
    
    $result = @"

$("=" * 80)
TEST: $TestName
$("=" * 80)
Método: $Method
URL: $Url
Timestamp: $(Get-Date -Format "HH:mm:ss")

REQUEST BODY:
$Body

STATUS CODE: $StatusCode

RESPONSE:
$($Response | ConvertTo-Json -Depth 10)

"@

    if ($ErrorMsg) {
        $result += @"
ERROR:
$ErrorMsg

"@
    }

    $result | Out-File $logFile -Append
    
    # También mostrar en consola
    Write-Host "`n$("=" * 80)" -ForegroundColor Cyan
    Write-Host "TEST: $TestName" -ForegroundColor Yellow
    Write-Host "$("=" * 80)" -ForegroundColor Cyan
    
    if ($StatusCode -ge 200 -and $StatusCode -lt 300) {
        Write-Host "✓ STATUS: $StatusCode" -ForegroundColor Green
    } else {
        Write-Host "✗ STATUS: $StatusCode" -ForegroundColor Red
    }
    
    if ($ErrorMsg) {
        Write-Host "ERROR: $ErrorMsg" -ForegroundColor Red
    }
}

function Invoke-ApiTest {
    param(
        [string]$TestName,
        [string]$Method,
        [string]$Endpoint,
        [string]$BodyJson = ""
    )
    
    $url = "$baseUrl$Endpoint"
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = $url
            Method = $Method
            Headers = $headers
        }
        
        if ($BodyJson -ne "") {
            $params.Body = $BodyJson
        }
        
        $response = Invoke-RestMethod @params -ErrorAction Stop
        $statusCode = 200
        
        Write-TestResult -TestName $TestName -Method $Method -Url $url -Body $BodyJson -Response $response -StatusCode $statusCode -ErrorMsg ""
        
        return $response
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = ""
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
        } catch {}
        
        Write-TestResult -TestName $TestName -Method $Method -Url $url -Body $BodyJson -Response $errorBody -StatusCode $statusCode -ErrorMsg $_.Exception.Message
        
        return $null
    }
}

Write-Host "`n╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     INICIANDO PRUEBAS - API TALLER MECÁNICO                      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`nLos resultados se guardarán en: $logFile`n" -ForegroundColor Yellow

# ============================================================================
# 01 - CASOS DE USO CLIENTE
# ============================================================================

Write-Host "`n█ 01 - CASOS DE USO CLIENTE" -ForegroundColor Magenta

# CA001 - Registrarse
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$body = @{
    NombreUsuario = "cliente_$timestamp"
    Password = "cliente123"
    CorreoElectronico = "cliente${timestamp}@test.com"
    NombreCompleto = "Cliente Test"
    Rol = 3
} | ConvertTo-Json

$result = Invoke-ApiTest -TestName "CA001 - Registrarse" -Method "POST" -Endpoint "/api/auth/registro" -BodyJson $body
if ($result -and $result.Id) {
    $global:clienteId = $result.Id
    Write-Host "  ✓ Cliente ID capturado: $global:clienteId" -ForegroundColor Green
}

# CA002 - Login Admin
$body = @{
    NombreUsuario = "admin"
    Password = "2345"
} | ConvertTo-Json

$result = Invoke-ApiTest -TestName "CA002 - Login Admin" -Method "POST" -Endpoint "/api/auth/login" -BodyJson $body

# CA003 - Solicitar Servicio
$body = @{
    ClienteId = $global:clienteId
    ClienteNombre = "Cliente Test"
    ServicioId = "srv123"
    ServicioNombre = "Cambio Aceite"
    Descripcion = "Necesito cambio de aceite urgente"
    Detalle = "Toyota Corolla 2020"
    Estado = 1
    EstadoSolicitud = 1
} | ConvertTo-Json

$result = Invoke-ApiTest -TestName "CA003 - Solicitar Servicio" -Method "POST" -Endpoint "/api/solicitud" -BodyJson $body
if ($result -and $result.Id) {
    $global:solicitudId = $result.Id
    Write-Host "  ✓ Solicitud ID capturado: $global:solicitudId" -ForegroundColor Green
}

# CA004 - Ver Solicitudes Cliente
Invoke-ApiTest -TestName "CA004 - Ver Solicitudes Cliente" -Method "GET" -Endpoint "/api/solicitud/cliente/$global:clienteId"

# CA005 - Ver Detalle Solicitud
Invoke-ApiTest -TestName "CA005 - Ver Detalle Solicitud" -Method "GET" -Endpoint "/api/solicitud/$global:solicitudId"

# CA006 - Ver Facturas
Invoke-ApiTest -TestName "CA006 - Ver Facturas Cliente" -Method "GET" -Endpoint "/api/factura/cliente/$global:clienteId"

# ============================================================================
# 02 - CASOS DE USO EMPLEADO
# ============================================================================

Write-Host "`n█ 02 - CASOS DE USO EMPLEADO" -ForegroundColor Magenta

# Primero crear empleado (para tener el ID)
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$body = @{
    NombreUsuario = "empleado_$timestamp"
    Password = "emp123"
    CorreoElectronico = "emp${timestamp}@test.com"
    NombreCompleto = "Empleado Test"
    PorcentajeComision = 0.15
    Activo = $true
    Rol = 2
} | ConvertTo-Json

$result = Invoke-ApiTest -TestName "CA011-A - Crear Empleado (previo)" -Method "POST" -Endpoint "/api/empleado" -BodyJson $body
if ($result -and $result.Id) {
    $global:empleadoId = $result.Id
    Write-Host "  ✓ Empleado ID capturado: $global:empleadoId" -ForegroundColor Green
}

# CA008 - Listar Solicitudes Pendientes
Invoke-ApiTest -TestName "CA008 - Listar Solicitudes Pendientes" -Method "GET" -Endpoint "/api/solicitud/pendientes"

# CA009 - Atender Solicitud
$body = @{
    EmpleadoId = $global:empleadoId
    EmpleadoNombre = "Empleado Test"
} | ConvertTo-Json

Invoke-ApiTest -TestName "CA009 - Atender Solicitud" -Method "PUT" -Endpoint "/api/solicitud/$global:solicitudId/asignar" -BodyJson $body

# ============================================================================
# 03 - CASOS DE USO ADMINISTRADOR
# ============================================================================

Write-Host "`n█ 03 - CASOS DE USO ADMINISTRADOR" -ForegroundColor Magenta

# CA011-B - Listar Empleados
Invoke-ApiTest -TestName "CA011-B - Listar Empleados" -Method "GET" -Endpoint "/api/empleado"

# CA011-C - Actualizar Empleado
$body = @{
    Id = $global:empleadoId
    NombreCompleto = "Empleado Test Actualizado"
    CorreoElectronico = "emp_actualizado@test.com"
    PorcentajeComision = 0.20
    Activo = $true
} | ConvertTo-Json

Invoke-ApiTest -TestName "CA011-C - Actualizar Empleado" -Method "PUT" -Endpoint "/api/empleado/$global:empleadoId" -BodyJson $body

# CA012-A - Crear Producto
$body = @{
    Nombre = "Aceite 5W-30"
    Descripcion = "Aceite sintético premium"
    Precio = 350
    Stock = 50
} | ConvertTo-Json

$result = Invoke-ApiTest -TestName "CA012-A - Crear Producto" -Method "POST" -Endpoint "/api/producto" -BodyJson $body
if ($result -and $result.Id) {
    $global:productoId = $result.Id
    Write-Host "  ✓ Producto ID capturado: $global:productoId" -ForegroundColor Green
}

# CA012-B - Listar Productos
Invoke-ApiTest -TestName "CA012-B - Listar Productos" -Method "GET" -Endpoint "/api/producto"

# CA012-C - Actualizar Stock
Invoke-ApiTest -TestName "CA012-C - Actualizar Stock" -Method "PUT" -Endpoint "/api/producto/$global:productoId/stock" -BodyJson "100"

# CA010 - Generar Factura
$body = @{
    SolicitudId = $global:solicitudId
    Detalles = @(
        @{
            ProductoId = $global:productoId
            ProductoNombre = "Aceite 5W-30"
            Cantidad = 2
            PrecioUnitario = 350
            Subtotal = 700
        }
    )
    PorcentajeComision = 0.80
} | ConvertTo-Json -Depth 10

$result = Invoke-ApiTest -TestName "CA010 - Generar Factura" -Method "POST" -Endpoint "/api/factura/generar" -BodyJson $body
if ($result -and $result.Id) {
    $global:facturaId = $result.Id
    Write-Host "  ✓ Factura ID capturada: $global:facturaId" -ForegroundColor Green
}

# CA013 - Ver Todas las Facturas
Invoke-ApiTest -TestName "CA013 - Ver Todas las Facturas" -Method "GET" -Endpoint "/api/factura"

# CA007 - Registrar Abono
$body = @{
    FacturaId = $global:facturaId
    ClienteId = $global:clienteId
    Monto = 500
    MetodoPago = "Efectivo"
} | ConvertTo-Json

Invoke-ApiTest -TestName "CA007 - Registrar Abono" -Method "POST" -Endpoint "/api/abono" -BodyJson $body

# CA011-D - Eliminar Empleado (al final para no afectar otras pruebas)
Invoke-ApiTest -TestName "CA011-D - Eliminar Empleado" -Method "DELETE" -Endpoint "/api/empleado/$global:empleadoId"

# ============================================================================
# RESUMEN
# ============================================================================

Write-Host "`n╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    PRUEBAS COMPLETADAS                            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`nResultados completos guardados en: $logFile" -ForegroundColor Yellow
Write-Host "`nRevisa el archivo para ver todos los detalles de requests y responses.`n" -ForegroundColor Gray

# Resumen de IDs capturados
"" | Out-File $logFile -Append
"=" * 80 | Out-File $logFile -Append
"RESUMEN DE IDS CAPTURADOS" | Out-File $logFile -Append
"=" * 80 | Out-File $logFile -Append
"Cliente ID: $global:clienteId" | Out-File $logFile -Append
"Empleado ID: $global:empleadoId" | Out-File $logFile -Append
"Producto ID: $global:productoId" | Out-File $logFile -Append
"Solicitud ID: $global:solicitudId" | Out-File $logFile -Append
"Factura ID: $global:facturaId" | Out-File $logFile -Append

Write-Host "IDs Capturados:" -ForegroundColor Yellow
Write-Host "  Cliente:   $global:clienteId" -ForegroundColor White
Write-Host "  Empleado:  $global:empleadoId" -ForegroundColor White
Write-Host "  Producto:  $global:productoId" -ForegroundColor White
Write-Host "  Solicitud: $global:solicitudId" -ForegroundColor White
Write-Host "  Factura:   $global:facturaId`n" -ForegroundColor White
