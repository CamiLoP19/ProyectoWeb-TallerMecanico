# Test FINAL - Todos los 13 Casos de Uso CORREGIDOS
$baseUrl = "http://localhost:5000"
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999

Write-Host "`n==============================================" -ForegroundColor Cyan
Write-Host "   TEST DE 13 CASOS DE USO - TALLER MECANICO" -ForegroundColor Cyan
Write-Host "==============================================`n" -ForegroundColor Cyan

# IDs globales
$clienteId = ""
$empleadoId = ""
$productoId = ""
$solicitudId = ""
$facturaId = ""

# CA001 - REGISTRARSE
Write-Host "CA001 - Registrarse (Cliente)" -ForegroundColor Yellow
try {
    $body = @{
        NombreUsuario = "cliente${timestamp}x$unique"
        Password = "Test1234!"
        CorreoElectronico = "cliente${timestamp}x${unique}@test.com"
        NombreCompleto = "Cliente Test Auto"
        Rol = 3
        RolUsuario = 3
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
    $clienteId = $response.Id
    Write-Host "  ✓ Cliente creado: $clienteId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA002 - LOGIN ADMIN
Write-Host "`nCA002 - Login Admin" -ForegroundColor Yellow
try {
    $body = @{
        NombreUsuario = "admin"
        Password = "2345"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-Host "  ✓ Login exitoso - Usuario: $($response.Usuario.NombreUsuario)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-A - CREAR EMPLEADO
Write-Host "`nCA011-A - Crear Empleado" -ForegroundColor Yellow
try {
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
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method POST -Body $body -ContentType "application/json"
    $empleadoId = $response.Id
    Write-Host "  ✓ Empleado creado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-A - CREAR PRODUCTO
Write-Host "`nCA012-A - Crear Producto" -ForegroundColor Yellow
try {
    $body = @{
        Nombre = "Producto Test $timestamp"
        Descripcion = "Producto de prueba automatica"
        Precio = 10000.0
        Stock = 50
        Activo = $true
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
    $productoId = $response.Id
    Write-Host "  ✓ Producto creado: $productoId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA003 - SOLICITAR SERVICIO
Write-Host "`nCA003 - Solicitar Servicio" -ForegroundColor Yellow
try {
    $body = @{
        ClienteId = $clienteId
        ClienteNombre = "Cliente Test Auto"
        ServicioId = "SRV_$timestamp"
        ServicioNombre = "Cambio de Aceite Test"
        Descripcion = "Solicitud de prueba automatica"
        Detalle = "Test $timestamp"
        Estado = 1
        EstadoSolicitud = 1
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud" -Method POST -Body $body -ContentType "application/json"
    $solicitudId = $response.Id
    Write-Host "  ✓ Solicitud creada: $solicitudId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA004 - VER SOLICITUDES CLIENTE
Write-Host "`nCA004 - Ver Solicitudes Cliente" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/cliente/$clienteId" -Method GET
    Write-Host "  ✓ Solicitudes del cliente: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA005 - VER DETALLE SOLICITUD
Write-Host "`nCA005 - Ver Detalle Solicitud" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId" -Method GET
    Write-Host "  ✓ Detalle obtenido - Estado: $($response.EstadoSolicitud)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA008 - LISTAR SOLICITUDES PENDIENTES
Write-Host "`nCA008 - Listar Solicitudes Pendientes" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/pendientes" -Method GET
    Write-Host "  ✓ Solicitudes pendientes: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA009 - ATENDER SOLICITUD (ASIGNAR)
Write-Host "`nCA009 - Atender Solicitud (Asignar)" -ForegroundColor Yellow
try {
    $body = @{
        EmpleadoId = $empleadoId
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$solicitudId/asignar" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  ✓ Solicitud asignada a empleado" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Obtener datos del producto para crear detalle de factura
$productoPrecio = 0
try {
    $prod = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId" -Method GET
    $productoPrecio = $prod.Precio
} catch {
    Write-Host "  ! Advertencia: No se pudo obtener precio del producto" -ForegroundColor Yellow
}

# CA010 - GENERAR FACTURA
Write-Host "`nCA010 - Generar Factura" -ForegroundColor Yellow
try {
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
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/generar" -Method POST -Body $body -ContentType "application/json"
    $facturaId = $response.Id
    Write-Host "  ✓ Factura generada: $facturaId - Total: $($response.Total)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# CA006 - VER FACTURAS CLIENTE
Write-Host "`nCA006 - Ver Facturas Cliente" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura/cliente/$clienteId" -Method GET
    Write-Host "  ✓ Facturas del cliente: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA007 - REGISTRAR ABONO
Write-Host "`nCA007 - Registrar Abono" -ForegroundColor Yellow
try {
    $body = @{
        FacturaId = $facturaId
        ClienteId = $clienteId
        Monto = 10000.0
        MetodoPago = "Efectivo"
        Observaciones = "Abono de prueba automatica"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/abono" -Method POST -Body $body -ContentType "application/json"
    Write-Host "  ✓ Abono registrado: $($response.Id) - Monto: $($response.Monto)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# CA011-B - LISTAR EMPLEADOS
Write-Host "`nCA011-B - Listar Empleados" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method GET
    Write-Host "  ✓ Empleados listados: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-C - ACTUALIZAR EMPLEADO
Write-Host "`nCA011-C - Actualizar Empleado" -ForegroundColor Yellow
try {
    # Obtener empleado actual completo
    $empActual = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method GET
    
    # Actualizar solo los campos que queremos cambiar
    $empActual.NombreCompleto = "Empleado Test ACTUALIZADO"
    $empActual.PorcentajeComision = 0.65
    
    $body = $empActual | ConvertTo-Json -Depth 10
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  ✓ Empleado actualizado" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# CA012-B - LISTAR PRODUCTOS
Write-Host "`nCA012-B - Listar Productos" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method GET
    Write-Host "  ✓ Productos listados: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA012-C - ACTUALIZAR STOCK
Write-Host "`nCA012-C - Actualizar Stock" -ForegroundColor Yellow
try {
    # El endpoint espera solo el número, no un objeto
    $nuevoStock = 60
    $body = $nuevoStock | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto/$productoId/stock" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "  ✓ Stock actualizado a: $($response.nuevoStock)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# CA013 - VER TODAS LAS FACTURAS
Write-Host "`nCA013 - Ver Todas Facturas (Admin)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/factura" -Method GET
    Write-Host "  ✓ Total facturas en sistema: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# CA011-D - ELIMINAR EMPLEADO
Write-Host "`nCA011-D - Eliminar Empleado" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$empleadoId" -Method DELETE
    Write-Host "  ✓ Empleado eliminado: $empleadoId" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# RESUMEN
Write-Host "`n==============================================" -ForegroundColor Cyan
Write-Host "   RESUMEN DE IDs GENERADOS" -ForegroundColor Cyan
Write-Host "==============================================`n" -ForegroundColor Cyan
Write-Host "Cliente:   " -NoNewline; Write-Host $clienteId -ForegroundColor White
Write-Host "Empleado:  " -NoNewline; Write-Host $empleadoId -ForegroundColor White
Write-Host "Producto:  " -NoNewline; Write-Host $productoId -ForegroundColor White
Write-Host "Solicitud: " -NoNewline; Write-Host $solicitudId -ForegroundColor White
Write-Host "Factura:   " -NoNewline; Write-Host $facturaId -ForegroundColor White
Write-Host "`n==============================================`n" -ForegroundColor Cyan
