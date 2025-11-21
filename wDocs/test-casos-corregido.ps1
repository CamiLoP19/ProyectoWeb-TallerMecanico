# Test Completo de Todos los Casos de Uso - CORREG IDO
$baseUrl = "http://localhost:5000"
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "   INICIANDO PRUEBAS DE CASOS DE USO" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

# Variables globales para IDs
$clienteId = ""
$empleadoId = ""
$productoId = ""
$solicitudId = ""
$facturaId = ""

$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999

#=================================================
# CA001 - REGISTRARSE (CLIENTE)
#=================================================
Write-Host "=== CA001 - Registrarse (Cliente) ===" -ForegroundColor Yellow
$body = @{
    NombreUsuario = "cliente${timestamp}x$unique"
    Password = "Test1234!"
    CorreoElectronico = "cliente${timestamp}x${unique}@test.com"
    NombreCompleto = "Cliente Test Automatico"
    Rol = 3
    RolUsuario = 3
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
    $clienteId = $response.Id
    Write-Host "✓ Cliente creado: $clienteId" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA002 - LOGIN ADMIN
#=================================================
Write-Host "`n=== CA002 - Login Admin ===" -ForegroundColor Yellow
$body = @{
    NombreUsuario = "admin"
    Password = "2345"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✓ Login exitoso - Usuario: $($response.Usuario.NombreUsuario)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA011-A - CREAR EMPLEADO  
#=================================================
Write-Host "`n=== CA011-A - Crear Empleado ===" -ForegroundColor Yellow
$body = @{
    NombreUsuario = "empleado${timestamp}x$unique"
    Password = "Test1234!"
    CorreoElectronico = "empleado${timestamp}x${unique}@test.com"
    NombreCompleto = "Empleado Test"
    Rol = 2
    RolUsuario = 2
    PorcentajeComision = 0.6
    Activo = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method POST -Body $body -ContentType "application/json"
    $empleadoId = $response.Id
    Write-Host "✓ Empleado creado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA012-A - CREAR PRODUCTO
#=================================================
Write-Host "`n=== CA012-A - Crear Producto ===" -ForegroundColor Yellow
$body = @{
    Nombre = "Producto Test $timestamp"
    Descripcion = "Producto de prueba automatica"
    Precio = 15000.0
    Stock = 50
    Activo = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
    $productoId = $response.Id
    Write-Host "✓ Producto creado: $productoId" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA003 - SOLICITAR SERVICIO
#=================================================
Write-Host "`n=== CA003 - Solicitar Servicio ===" -ForegroundColor Yellow
$body = @{
    ClienteId = $clienteId
    ClienteNombre = "Cliente Test Automatico"
    ServicioId = "SRV_TEST_$timestamp"
    ServicioNombre = "Mantenimiento General Test"
    Descripcion = "Solicitud de prueba automatica"
    Detalle = "Test - $timestamp"
    Estado = 1
    EstadoSolicitud = 1
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud" -Method POST -Body $body -ContentType "application/json"
    $solicitudId = $response.Id
    Write-Host "✓ Solicitud creada: $solicitudId" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA004 - VER SOLICITUDES CLIENTE
#=================================================
Write-Host "`n=== CA004 - Ver Solicitudes Cliente ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/cliente/$clienteId" -Method GET
    Write-Host "✓ Solicitudes obtenidas: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA005 - VER DETALLE SOLICITUD
#=================================================
Write-Host "`n=== CA005 - Ver Detalle Solicitud ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId" -Method GET
    Write-Host "✓ Detalle obtenido - Estado: $($response.EstadoSolicitud)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA008 - LISTAR SOLICITUDES PENDIENTES
#=================================================
Write-Host "`n=== CA008 - Listar Solicitudes Pendientes ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/pendientes" -Method GET
    Write-Host "✓ Solicitudes pendientes: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA009 - ATENDER SOLICITUD (ASIGNAR EMPLEADO)
#=================================================
Write-Host "`n=== CA009 - Atender Solicitud (Asignar Empleado) ===" -ForegroundColor Yellow
$body = @{
    EmpleadoId = $empleadoId
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId/asignar" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "✓ Solicitud asignada a empleado" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA010 - GENERAR FACTURA
#=================================================
Write-Host "`n=== CA010 - Generar Factura ===" -ForegroundColor Yellow
$body = @{
    SolicitudId = $solicitudId
    EmpleadoId = $empleadoId
    ProductosUtilizados = @(
        @{
            ProductoId = $productoId
            Cantidad = 2
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/generar" -Method POST -Body $body -ContentType "application/json"
    $facturaId = $response.Id
    Write-Host "✓ Factura generada: $facturaId - Total: $($response.Total)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA006 - VER FACTURAS CLIENTE
#=================================================
Write-Host "`n=== CA006 - Ver Facturas Cliente ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/cliente/$clienteId" -Method GET
    Write-Host "✓ Facturas del cliente: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA007 - REGISTRAR ABONO
#=================================================
Write-Host "`n=== CA007 - Registrar Abono ===" -ForegroundColor Yellow
$body = @{
    FacturaId = $facturaId
    ClienteId = $clienteId
    Monto = 15000.0
    MetodoPago = "Efectivo"
    Observaciones = "Abono parcial de prueba"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/abono" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✓ Abono registrado: $($response.Id) - Monto: $($response.Monto)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA011-B - LISTAR EMPLEADOS
#=================================================
Write-Host "`n=== CA011-B - Listar Empleados ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method GET
    Write-Host "✓ Empleados listados: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA011-C - ACTUALIZAR EMPLEADO
#=================================================
Write-Host "`n=== CA011-C - Actualizar Empleado ===" -ForegroundColor Yellow
$body = @{
    NombreCompleto = "Empleado Test ACTUALIZADO"
    CorreoElectronico = "empleado${timestamp}x${unique}@test.com"
    PorcentajeComision = 0.65
    Activo = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "✓ Empleado actualizado" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA012-B - LISTAR PRODUCTOS
#=================================================
Write-Host "`n=== CA012-B - Listar Productos ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method GET
    Write-Host "✓ Productos listados: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA012-C - ACTUALIZAR STOCK PRODUCTO
#=================================================
Write-Host "`n=== CA012-C - Actualizar Stock Producto ===" -ForegroundColor Yellow
$body = @{
    CantidadCambio = 10
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId/stock" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "✓ Stock actualizado - Nuevo stock: $($response.Stock)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# CA013 - VER TODAS LAS FACTURAS (ADMIN)
#=================================================
Write-Host "`n=== CA013 - Ver Todas las Facturas (Admin) ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura" -Method GET
    Write-Host "✓ Total de facturas: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

#=================================================
# CA011-D - ELIMINAR EMPLEADO
#=================================================
Write-Host "`n=== CA011-D - Eliminar Empleado ===" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method DELETE
    Write-Host "✓ Empleado eliminado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
}

#=================================================
# RESUMEN
#=================================================
Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "   PRUEBAS COMPLETADAS" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "`nIDs Capturados:" -ForegroundColor Yellow
Write-Host "  Cliente:   $clienteId" -ForegroundColor White
Write-Host "  Empleado:  $empleadoId" -ForegroundColor White
Write-Host "  Producto:  $productoId" -ForegroundColor White
Write-Host "  Solicitud: $solicitudId" -ForegroundColor White
Write-Host "  Factura:   $facturaId" -ForegroundColor White
Write-Host ""
