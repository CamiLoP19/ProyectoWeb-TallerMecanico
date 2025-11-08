# Script de Configuración Inicial - ProyectoWeb
# Este script te ayudará a configurar el proyecto para ejecutarlo por primera vez

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Configuración Inicial - ProyectoWeb" -ForegroundColor Cyan
Write-Host "   ASP.NET Core + Blazor + Firebase" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar .NET SDK
Write-Host "1. Verificando .NET SDK..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "   ✓ .NET SDK instalado: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ .NET SDK no encontrado" -ForegroundColor Red
    Write-Host "   Por favor instala .NET 8.0 SDK desde: https://dotnet.microsoft.com/download" -ForegroundColor Red
    exit 1
}

# Verificar que estamos en la carpeta correcta
if (-not (Test-Path "ProyectoWeb.csproj")) {
    Write-Host "   ✗ No se encontró ProyectoWeb.csproj" -ForegroundColor Red
    Write-Host "   Ejecuta este script desde la carpeta ProyectoWeb" -ForegroundColor Red
    exit 1
}

# Restaurar paquetes NuGet
Write-Host ""
Write-Host "2. Restaurando paquetes NuGet..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Paquetes restaurados correctamente" -ForegroundColor Green
} else {
    Write-Host "   ✗ Error al restaurar paquetes" -ForegroundColor Red
    exit 1
}

# Verificar archivo de credenciales de Firebase
Write-Host ""
Write-Host "3. Verificando credenciales de Firebase..." -ForegroundColor Yellow
if (-not (Test-Path "firebase-credentials.json")) {
    Write-Host "   ⚠ Archivo firebase-credentials.json no encontrado" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   IMPORTANTE: Necesitas configurar Firebase para ejecutar la aplicación" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Pasos:" -ForegroundColor White
    Write-Host "   1. Ve a https://console.firebase.google.com/" -ForegroundColor White
    Write-Host "   2. Crea o selecciona un proyecto" -ForegroundColor White
    Write-Host "   3. Habilita Firestore Database" -ForegroundColor White
    Write-Host "   4. Ve a Configuración → Cuentas de servicio" -ForegroundColor White
    Write-Host "   5. Genera una nueva clave privada (descarga el JSON)" -ForegroundColor White
    Write-Host "   6. Guarda el archivo como firebase-credentials.json en esta carpeta" -ForegroundColor White
    Write-Host ""
    
    $respuesta = Read-Host "¿Ya tienes el archivo firebase-credentials.json? (S/N)"
    if ($respuesta -eq "S" -or $respuesta -eq "s") {
        Write-Host "   Por favor coloca el archivo firebase-credentials.json en esta carpeta y vuelve a ejecutar el script" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "   Puedes continuar sin Firebase, pero la aplicación no funcionará completamente" -ForegroundColor Yellow
        Write-Host "   Se usará un archivo de ejemplo temporal" -ForegroundColor Yellow
        
        # Crear archivo temporal de ejemplo
        @"
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
"@ | Out-File -FilePath "firebase-credentials.json" -Encoding UTF8
    }
} else {
    Write-Host "   ✓ Archivo firebase-credentials.json encontrado" -ForegroundColor Green
}

# Verificar y configurar appsettings.json
Write-Host ""
Write-Host "4. Configurando appsettings.json..." -ForegroundColor Yellow

if (Test-Path "firebase-credentials.json") {
    try {
        $firebaseContent = Get-Content "firebase-credentials.json" | ConvertFrom-Json
        $projectId = $firebaseContent.project_id
        
        if ($projectId -and $projectId -ne "CONFIGURA_TU_PROJECT_ID") {
            Write-Host "   Project ID detectado: $projectId" -ForegroundColor Cyan
            
            # Actualizar appsettings.json
            $appsettings = Get-Content "appsettings.json" | ConvertFrom-Json
            $appsettings.Firebase.ProjectId = $projectId
            $appsettings.Firebase.CredentialsPath = "firebase-credentials.json"
            $appsettings | ConvertTo-Json -Depth 10 | Set-Content "appsettings.json"
            
            # Actualizar appsettings.Development.json
            $appsettingsDev = Get-Content "appsettings.Development.json" | ConvertFrom-Json
            $appsettingsDev.Firebase.ProjectId = $projectId
            $appsettingsDev.Firebase.CredentialsPath = "firebase-credentials.json"
            $appsettingsDev | ConvertTo-Json -Depth 10 | Set-Content "appsettings.Development.json"
            
            Write-Host "   ✓ appsettings.json configurado correctamente" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Project ID no válido en firebase-credentials.json" -ForegroundColor Yellow
            Write-Host "   Debes configurar manualmente el Project ID en appsettings.json" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠ No se pudo leer firebase-credentials.json" -ForegroundColor Yellow
    }
}

# Compilar el proyecto
Write-Host ""
Write-Host "5. Compilando el proyecto..." -ForegroundColor Yellow
dotnet build
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Proyecto compilado correctamente" -ForegroundColor Green
} else {
    Write-Host "   ✗ Error al compilar el proyecto" -ForegroundColor Red
    Write-Host "   Revisa los errores anteriores" -ForegroundColor Red
    exit 1
}

# Resumen
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Configuración Completada" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para ejecutar la aplicación:" -ForegroundColor White
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host ""
Write-Host "O presiona F5 en Visual Studio" -ForegroundColor White
Write-Host ""
Write-Host "La aplicación estará disponible en:" -ForegroundColor White
Write-Host "   https://localhost:7xxx" -ForegroundColor Cyan
Write-Host "   http://localhost:5xxx" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recursos:" -ForegroundColor White
Write-Host "   - README.md: Documentación completa" -ForegroundColor Gray
Write-Host "   - GUIA_MIGRACION.md: Guía de migración" -ForegroundColor Gray
Write-Host "   - DESPLIEGUE.md: Instrucciones de despliegue" -ForegroundColor Gray
Write-Host ""

# Preguntar si desea ejecutar la aplicación
$ejecutar = Read-Host "¿Deseas ejecutar la aplicación ahora? (S/N)"
if ($ejecutar -eq "S" -or $ejecutar -eq "s") {
    Write-Host ""
    Write-Host "Iniciando aplicación..." -ForegroundColor Green
    Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow
    Write-Host ""
    dotnet run
}
