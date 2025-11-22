# Test 13 Casos de Uso - Version Simplificada
$baseUrl = "http://localhost:5000"
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999

Write-Host ""
Write-Host "=============================================="
Write-Host "TEST DE 13 CASOS DE USO - TALLER MECANICO"
Write-Host "=============================================="
Write-Host ""

$clienteId = ""
$empleadoId = ""
$productoId = ""
$solicitudId = ""
$facturaId = ""

# CA001 - REGISTRARSE
Write-Host "[CA001] Registrarse"
$body = @{
    NombreUsuario = "cli${timestamp}x$unique"
    Password = "Test1234!"
    CorreoElectronico = "cli${timestamp}x${unique}@test.com"
    NombreCompleto = "Cliente Test"
    Rol = 3
    RolUsuario = 3
} | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
    $clienteId = $r.Id
    Write-Host "  OK - Cliente: $clienteId" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA002 - LOGIN ADMIN
Write-Host ""
Write-Host "[CA002] Login Admin"
$body = @{ NombreUsuario = "admin"; Password = "2345" } | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-Host "  OK - Usuario: $($r.Usuario.NombreUsuario)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-A - CREAR EMPLEADO
Write-Host ""
Write-Host "[CA011-A] Crear Empleado"
$body = @{
    NombreUsuario = "emp${timestamp}x$unique"
    Password = "Test1234!"
    CorreoElectronico = "emp${timestamp}x${unique}@test.com"
    NombreCompleto = "Empleado Test"
    Rol = 2
    RolUsuario = 2
    PorcentajeComision = 0.6
    Activo = $true
} | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method POST -Body $body -ContentType "application/json"
    $empleadoId = $r.Id
    Write-Host "  OK - Empleado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-A - CREAR PRODUCTO
Write-Host ""
Write-Host "[CA012-A] Crear Producto"
$body = @{
    Nombre = "Producto Test $timestamp"
    Descripcion = "Producto de prueba"
    Precio = 10000.0
    Stock = 50
    Activo = $true
} | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
    $productoId = $r.Id
    Write-Host "  OK - Producto: $productoId" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA003 - SOLICITAR SERVICIO
Write-Host ""
Write-Host "[CA003] Solicitar Servicio"
$body = @{
    ClienteId = $clienteId
    ClienteNombre = "Cliente Test"
    ServicioId = "SRV_$timestamp"
    ServicioNombre = "Cambio Aceite"
    Descripcion = "Solicitud de prueba"
    Detalle = "Test $timestamp"
    Estado = 1
    EstadoSolicitud = 1
} | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/solicitud" -Method POST -Body $body -ContentType "application/json"
    $solicitudId = $r.Id
    Write-Host "  OK - Solicitud: $solicitudId" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA004 - VER SOLICITUDES CLIENTE
Write-Host ""
Write-Host "[CA004] Ver Solicitudes Cliente"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/cliente/$clienteId" -Method GET
    Write-Host "  OK - Solicitudes: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA005 - VER DETALLE SOLICITUD
Write-Host ""
Write-Host "[CA005] Ver Detalle Solicitud"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId" -Method GET
    Write-Host "  OK - Estado: $($r.EstadoSolicitud)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA008 - LISTAR SOLICITUDES PENDIENTES
Write-Host ""
Write-Host "[CA008] Listar Pendientes"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/pendientes" -Method GET
    Write-Host "  OK - Pendientes: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA009 - ATENDER SOLICITUD
Write-Host ""
Write-Host "[CA009] Atender Solicitud"
$body = @{ EmpleadoId = $empleadoId } | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId/asignar" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  OK - Asignada" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Obtener precio del producto
$productoPrecio = 0
try {
    $prod = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId" -Method GET
    $productoPrecio = $prod.Precio
} catch {}

# CA010 - GENERAR FACTURA
Write-Host ""
Write-Host "[CA010] Generar Factura"
$body = @{
    SolicitudId = $solicitudId
    Detalles = @(
        @{
            ProductoId = $productoId
            ProductoNombre = "Producto Test $timestamp"
            Cantidad = 2
            PrecioUnitario = $productoPrecio
            Subtotal = $productoPrecio * 2
        }
    )
    PorcentajeComision = 0.6
} | ConvertTo-Json -Depth 10

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/factura/generar" -Method POST -Body $body -ContentType "application/json"
    $facturaId = $r.Id
    Write-Host "  OK - Factura: $facturaId - Total: $($r.Total)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA006 - VER FACTURAS CLIENTE
Write-Host ""
Write-Host "[CA006] Ver Facturas Cliente"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/factura/cliente/$clienteId" -Method GET
    Write-Host "  OK - Facturas: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA007 - REGISTRAR ABONO
Write-Host ""
Write-Host "[CA007] Registrar Abono"
$body = @{
    FacturaId = $facturaId
    ClienteId = $clienteId
    Monto = 10000.0
    MetodoPago = "Efectivo"
    Observaciones = "Abono de prueba"
} | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/abono" -Method POST -Body $body -ContentType "application/json"
    Write-Host "  OK - Abono: $($r.Id) - Monto: $($r.Monto)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-B - LISTAR EMPLEADOS
Write-Host ""
Write-Host "[CA011-B] Listar Empleados"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method GET
    Write-Host "  OK - Empleados: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-C - ACTUALIZAR EMPLEADO
Write-Host ""
Write-Host "[CA011-C] Actualizar Empleado"
try {
    $empActual = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method GET
    $empActual.NombreCompleto = "Empleado Test ACTUALIZADO"
    $empActual.PorcentajeComision = 0.65
    $body = $empActual | ConvertTo-Json -Depth 10
    
    $r = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  OK - Actualizado" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-B - LISTAR PRODUCTOS
Write-Host ""
Write-Host "[CA012-B] Listar Productos"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method GET
    Write-Host "  OK - Productos: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-C - ACTUALIZAR STOCK
Write-Host ""
Write-Host "[CA012-C] Actualizar Stock"
$nuevoStock = 60
$body = $nuevoStock | ConvertTo-Json

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId/stock" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  OK - Nuevo stock: $($r.nuevoStock)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA013 - VER TODAS LAS FACTURAS
Write-Host ""
Write-Host "[CA013] Ver Todas Facturas"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/factura" -Method GET
    Write-Host "  OK - Total: $($r.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-D - ELIMINAR EMPLEADO
Write-Host ""
Write-Host "[CA011-D] Eliminar Empleado"
try {
    $r = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method DELETE
    Write-Host "  OK - Eliminado" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# RESUMEN
Write-Host ""
Write-Host "=============================================="
Write-Host "RESUMEN"
Write-Host "=============================================="
Write-Host "Cliente:   $clienteId"
Write-Host "Empleado:  $empleadoId"
Write-Host "Producto:  $productoId"
Write-Host "Solicitud: $solicitudId"
Write-Host "Factura:   $facturaId"
Write-Host "=============================================="
Write-Host ""
