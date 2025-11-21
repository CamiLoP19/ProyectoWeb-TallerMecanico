# Test Casos de Uso - FIXED
$baseUrl = "http://localhost:5000"
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999

Write-Host "`n========== INICIANDO PRUEBAS ==========" -ForegroundColor Cyan

# IDs globales
$clienteId = ""
$empleadoId = ""
$productoId = ""
$solicitudId = ""
$facturaId = ""

# CA001 - REGISTRARSE
Write-Host "`nCA001 - Registrarse" -ForegroundColor Yellow
try {
    $body = @{
        NombreUsuario = "cliente${timestamp}x$unique"
        Password = "Test1234!"
        CorreoElectronico = "cliente${timestamp}x${unique}@test.com"
        NombreCompleto = "Cliente Test"
        Rol = 3
        RolUsuario = 3
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
    $clienteId = $response.Id
    Write-Host "OK - Cliente: $clienteId" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA002 - LOGIN ADMIN
Write-Host "`nCA002 - Login Admin" -ForegroundColor Yellow
try {
    $body = @{
        NombreUsuario = "admin"
        Password = "2345"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-Host "OK - Usuario: $($response.Usuario.NombreUsuario)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-A - CREAR EMPLEADO
Write-Host "`nCA011-A - Crear Empleado" -ForegroundColor Yellow
try {
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
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method POST -Body $body -ContentType "application/json"
    $empleadoId = $response.Id
    Write-Host "OK - Empleado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-A - CREAR PRODUCTO
Write-Host "`nCA012-A - Crear Producto" -ForegroundColor Yellow
try {
    $body = @{
        Nombre = "Producto Test $timestamp"
        Descripcion = "Producto de prueba"
        Precio = 15000.0
        Stock = 50
        Activo = $true
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
    $productoId = $response.Id
    Write-Host "OK - Producto: $productoId" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA003 - SOLICITAR SERVICIO
Write-Host "`nCA003 - Solicitar Servicio" -ForegroundColor Yellow
try {
    $body = @{
        ClienteId = $clienteId
        ClienteNombre = "Cliente Test"
        ServicioId = "SRV_TEST_$timestamp"
        ServicioNombre = "Mantenimiento Test"
        Descripcion = "Solicitud de prueba"
        Detalle = "Test $timestamp"
        Estado = 1
        EstadoSolicitud = 1
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud" -Method POST -Body $body -ContentType "application/json"
    $solicitudId = $response.Id
    Write-Host "OK - Solicitud: $solicitudId" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA004 - VER SOLICITUDES CLIENTE
Write-Host "`nCA004 - Ver Solicitudes Cliente" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/cliente/$clienteId" -Method GET
    Write-Host "OK - Solicitudes: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA005 - VER DETALLE SOLICITUD
Write-Host "`nCA005 - Ver Detalle Solicitud" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId" -Method GET
    Write-Host "OK - Estado: $($response.EstadoSolicitud)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA008 - LISTAR SOLICITUDES PENDIENTES
Write-Host "`nCA008 - Listar Pendientes" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/pendientes" -Method GET
    Write-Host "OK - Pendientes: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA009 - ATENDER SOLICITUD
Write-Host "`nCA009 - Atender Solicitud" -ForegroundColor Yellow
try {
    $body = @{
        EmpleadoId = $empleadoId
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId/asignar" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "OK - Solicitud asignada" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA010 - GENERAR FACTURA
Write-Host "`nCA010 - Generar Factura" -ForegroundColor Yellow
try {
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
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/generar" -Method POST -Body $body -ContentType "application/json"
    $facturaId = $response.Id
    Write-Host "OK - Factura: $facturaId - Total: $($response.Total)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA006 - VER FACTURAS CLIENTE
Write-Host "`nCA006 - Ver Facturas Cliente" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/cliente/$clienteId" -Method GET
    Write-Host "OK - Facturas: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA007 - REGISTRAR ABONO
Write-Host "`nCA007 - Registrar Abono" -ForegroundColor Yellow
try {
    $body = @{
        FacturaId = $facturaId
        ClienteId = $clienteId
        Monto = 15000.0
        MetodoPago = "Efectivo"
        Observaciones = "Abono de prueba"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/abono" -Method POST -Body $body -ContentType "application/json"
    Write-Host "OK - Abono: $($response.Id) - Monto: $($response.Monto)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-B - LISTAR EMPLEADOS
Write-Host "`nCA011-B - Listar Empleados" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method GET
    Write-Host "OK - Empleados: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-C - ACTUALIZAR EMPLEADO
Write-Host "`nCA011-C - Actualizar Empleado" -ForegroundColor Yellow
try {
    $body = @{
        NombreCompleto = "Empleado Test ACTUALIZADO"
        CorreoElectronico = "empleado${timestamp}x${unique}@test.com"
        PorcentajeComision = 0.65
        Activo = $true
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "OK - Empleado actualizado" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-B - LISTAR PRODUCTOS
Write-Host "`nCA012-B - Listar Productos" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method GET
    Write-Host "OK - Productos: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-C - ACTUALIZAR STOCK
Write-Host "`nCA012-C - Actualizar Stock" -ForegroundColor Yellow
try {
    $body = @{
        CantidadCambio = 10
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId/stock" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "OK - Nuevo stock: $($response.Stock)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA013 - VER TODAS LAS FACTURAS
Write-Host "`nCA013 - Ver Todas Facturas" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura" -Method GET
    Write-Host "OK - Total facturas: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-D - ELIMINAR EMPLEADO
Write-Host "`nCA011-D - Eliminar Empleado" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method DELETE
    Write-Host "OK - Empleado eliminado" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# RESUMEN
Write-Host "`n========== RESUMEN ==========" -ForegroundColor Cyan
Write-Host "Cliente:   $clienteId"
Write-Host "Empleado:  $empleadoId"
Write-Host "Producto:  $productoId"
Write-Host "Solicitud: $solicitudId"
Write-Host "Factura:   $facturaId"
Write-Host "============================`n" -ForegroundColor Cyan
