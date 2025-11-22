# Test crear producto
$baseUrl = "http://localhost:5000"

Write-Host "=== Crear Producto ===" -ForegroundColor Yellow
$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$body = @{
    Nombre = "Producto Test $timestamp"
    Descripcion = "Producto de prueba automatica"
    Precio = 15000.0
    Stock = 50
    Activo = $true
} | ConvertTo-Json

Write-Host "Body:" -ForegroundColor Cyan
Write-Host $body

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/producto" -Method POST -Body $body -ContentType "application/json"
    Write-Host "`nRespuesta:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    Write-Host "`nProducto ID: $($response.Id)" -ForegroundColor Green
} catch {
    Write-Host "`nERROR:" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Host "`nError Details:"
        Write-Host $_.ErrorDetails.Message
    }
}
