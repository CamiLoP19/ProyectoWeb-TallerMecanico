# Test Debug - Ver estructura de respuestas
$baseUrl = "http://localhost:5000"
Write-Host "=== Test de Registro ===" -ForegroundColor Cyan

$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
$unique = Get-Random -Minimum 10000 -Maximum 99999
$body = @{
    NombreUsuario = "debug${timestamp}x$unique"
    Password = "Test1234!"
    CorreoElectronico = "debug${timestamp}x${unique}@test.com"
    NombreCompleto = "Debug Test"
    Rol = 3
    RolUsuario = 3
} | ConvertTo-Json

Write-Host "Body enviado:"
Write-Host $body

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/registro" -Method POST -Body $body -ContentType "application/json"
    
    Write-Host ""
    Write-Host "RESPUESTA RECIBIDA:" -ForegroundColor Green
    Write-Host "Tipo: $($response.GetType().FullName)"
    Write-Host ""
    Write-Host "Propiedades disponibles:"
    $response.PSObject.Properties | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Value)"
    }
    
    Write-Host ""
    Write-Host "JSON completo:"
    $response | ConvertTo-Json -Depth 10
    
    Write-Host ""
    Write-Host "Intentando capturar ID:"
    if ($response.Id) {
        Write-Host "  Id encontrado: $($response.Id)" -ForegroundColor Green
    } elseif ($response.id) {
        Write-Host "  id (minuscula) encontrado: $($response.id)" -ForegroundColor Green  
    } elseif ($response.clienteId) {
        Write-Host "  clienteId encontrado: $($response.clienteId)" -ForegroundColor Green
    } else {
        Write-Host "  NO se encontro campo de ID" -ForegroundColor Red
    }
    
} catch {
    Write-Host ""
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)"
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)"
    
    if ($_.ErrorDetails) {
        Write-Host ""
        Write-Host "Error Details:"
        Write-Host $_.ErrorDetails.Message
    }
    
    # Intentar leer el response body
    try {
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $responseBody = $reader.ReadToEnd()
        Write-Host ""
        Write-Host "Response Body:"
        Write-Host $responseBody
    } catch {
        Write-Host "No se pudo leer response body"
    }
}
