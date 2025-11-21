# Diagnosticar los 3 errores
$baseUrl = "http://localhost:5000"

# Primero crear los datos necesarios
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999

# Crear cliente
Write-Host "Creando cliente..." -ForegroundColor Cyan
$body = @{
    NombreUsuario = "clientetest${timestamp}"
    Password = "Test1234!"
    CorreoElectronico = "clientetest${timestamp}@test.com"
    NombreCompleto = "Cliente Test"
    Rol = 3
    RolUsuario = 3
} | ConvertTo-Json
$cliente = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
Write-Host "Cliente ID: $($cliente.Id)" -ForegroundColor Green

# Crear empleado
Write-Host "`nCreando empleado..." -ForegroundColor Cyan
$body = @{
    NombreUsuario = "emptest${timestamp}"
    Password = "Test1234!"
    CorreoElectronico = "emptest${timestamp}@test.com"
    NombreCompleto = "Empleado Test"
    Rol = 2
    RolUsuario = 2
    PorcentajeComision = 0.6
    Activo = $true
} | ConvertTo-Json
$empleado = Invoke-RestMethod -Uri "$baseUrl/api/empleado" -Method POST -Body $body -ContentType "application/json"
Write-Host "Empleado ID: $($empleado.Id)" -ForegroundColor Green

# Crear producto
Write-Host "`nCreando producto..." -ForegroundColor Cyan
$body = @{
    Nombre = "Producto $timestamp"
    Descripcion = "Test"
    Precio = 10000.0
    Stock = 50
    Activo = $true
} | ConvertTo-Json
$producto = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
Write-Host "Producto ID: $($producto.Id)" -ForegroundColor Green

# Crear solicitud y asignar
Write-Host "`nCreando solicitud..." -ForegroundColor Cyan
$body = @{
    ClienteId = $cliente.Id
    ClienteNombre = "Cliente Test"
    ServicioId = "SRV_$timestamp"
    ServicioNombre = "Servicio Test"
    Descripcion = "Test"
    Detalle = "Test"
    Estado = 1
    EstadoSolicitud = 1
} | ConvertTo-Json
$solicitud = Invoke-RestMethod -Uri "$baseUrl/api/solicitud" -Method POST -Body $body -ContentType "application/json"
Write-Host "Solicitud ID: $($solicitud.Id)" -ForegroundColor Green

Write-Host "`nAsignando solicitud..." -ForegroundColor Cyan
$body = @{ EmpleadoId = $empleado.Id } | ConvertTo-Json
Invoke-RestMethod -Uri "$baseUrl/api/solicitud/$($solicitud.Id)/asignar" -Method PUT -Body $body -ContentType "application/json"
Write-Host "Solicitud asignada" -ForegroundColor Green

# Crear factura
Write-Host "`nGenerando factura..." -ForegroundColor Cyan
$body = @{
    SolicitudId = $solicitud.Id
    EmpleadoId = $empleado.Id
    ProductosUtilizados = @(
        @{
            ProductoId = $producto.Id
            Cantidad = 2
        }
    )
} | ConvertTo-Json -Depth 10
$factura = Invoke-RestMethod -Uri "$baseUrl/api/factura/generar" -Method POST -Body $body -ContentType "application/json"
Write-Host "Factura ID: $($factura.Id)" -ForegroundColor Green
Write-Host "Factura Total: $($factura.Total)" -ForegroundColor Yellow
Write-Host "Factura JSON:" -ForegroundColor Yellow
$factura | ConvertTo-Json -Depth 10

# TEST 1: Registrar Abono
Write-Host "`n==== TEST 1: Registrar Abono ====" -ForegroundColor Magenta
$body = @{
    FacturaId = $factura.Id
    ClienteId = $cliente.Id
    Monto = 5000.0
    MetodoPago = "Efectivo"
    Observaciones = "Test"
} | ConvertTo-Json

Write-Host "Body enviado:" -ForegroundColor Cyan
Write-Host $body

try {
    $abono = Invoke-RestMethod -Uri "$baseUrl/api/abono" -Method POST -Body $body -ContentType "application/json"
    Write-Host "OK - Abono creado: $($abono.Id)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalles:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message
    }
}

# TEST 2: Actualizar Empleado
Write-Host "`n==== TEST 2: Actualizar Empleado ====" -ForegroundColor Magenta
$body = @{
    NombreCompleto = "Empleado ACTUALIZADO"
    CorreoElectronico = "emptest${timestamp}@test.com"
    PorcentajeComision = 0.65
    Activo = $true
} | ConvertTo-Json

Write-Host "Body enviado:" -ForegroundColor Cyan
Write-Host $body

try {
    $empActualizado = Invoke-RestMethod -Uri "$baseUrl/api/empleado/$($empleado.Id)" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "OK - Empleado actualizado" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalles:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message
    }
}

# TEST 3: Actualizar Stock
Write-Host "`n==== TEST 3: Actualizar Stock ====" -ForegroundColor Magenta
$body = @{
    CantidadCambio = 10
} | ConvertTo-Json

Write-Host "Body enviado:" -ForegroundColor Cyan
Write-Host $body

try {
    $prodActualizado = Invoke-RestMethod -Uri "$baseUrl/api/producto/$($producto.Id)/stock" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "OK - Stock actualizado a: $($prodActualizado.Stock)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalles:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message
    }
}
