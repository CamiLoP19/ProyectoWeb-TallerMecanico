# Script para verificar y actualizar la contraseña del usuario camilos
# Este script calcula el hash SHA256 correcto de la contraseña "1234"

Write-Host "=== VERIFICADOR DE PASSWORD HASH SHA256 ===" -ForegroundColor Cyan
Write-Host ""

# Contraseña que queremos hashear
$password = "1234"

# Crear el objeto SHA256
$sha256 = [System.Security.Cryptography.SHA256]::Create()

# Convertir la contraseña a bytes
$passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($password)

# Calcular el hash
$hashBytes = $sha256.ComputeHash($passwordBytes)

# Convertir a string hexadecimal (como lo hace tu código C#)
$hashString = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()

Write-Host "Password original: $password" -ForegroundColor Yellow
Write-Host "Hash SHA256 correcto: $hashString" -ForegroundColor Green
Write-Host ""
Write-Host "INSTRUCCIONES:" -ForegroundColor Cyan
Write-Host "1. Ve a Firebase Console: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "2. Selecciona tu proyecto" -ForegroundColor White
Write-Host "3. Ve a Firestore Database" -ForegroundColor White
Write-Host "4. Busca la colección 'usuarios'" -ForegroundColor White
Write-Host "5. Encuentra el documento del usuario 'camilos'" -ForegroundColor White
Write-Host "6. Edita el campo 'password' y reemplázalo con:" -ForegroundColor White
Write-Host "   $hashString" -ForegroundColor Yellow
Write-Host ""
Write-Host "Alternativamente, copia este hash y guárdalo para usarlo en tu aplicación." -ForegroundColor White
Write-Host ""

# Guardar en archivo temporal
$hashString | Out-File -FilePath "password-hash.txt" -Encoding UTF8
Write-Host "✅ Hash guardado en: password-hash.txt" -ForegroundColor Green
