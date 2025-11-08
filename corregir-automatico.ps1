# Script para corregir automáticamente los issues más comunes de SonarCloud
# Ejecutar desde: c:\Users\janer\ProyectoWeb

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CORRECTOR AUTOMATICO DE ISSUES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$projectPath = ".\ProyectoWeb"
$archivosModificados = 0

# Hacer backup primero
Write-Host "Creando backup..." -ForegroundColor Yellow
$backupFolder = ".\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -Path $projectPath -Destination $backupFolder -Recurse
Write-Host "✓ Backup creado en: $backupFolder" -ForegroundColor Green
Write-Host ""

# Obtener todos los archivos .cs (excluyendo obj y bin)
$archivos = Get-ChildItem -Path $projectPath -Recurse -Include *.cs | 
    Where-Object { $_.FullName -notmatch "\\obj\\" -and $_.FullName -notmatch "\\bin\\" }

Write-Host "Archivos a procesar: $($archivos.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($archivo in $archivos) {
    Write-Host "Procesando: $($archivo.Name)" -ForegroundColor Yellow
    
    $contenido = Get-Content $archivo.FullName -Raw
    $contenidoOriginal = $contenido
    $cambios = 0
    
    # 1. CORREGIR LOGGING NO ESTRUCTURADO (S2629) - 103 issues
    # Buscar patrones como: LogInformation("texto" + variable)
    $patronesLogging = @(
        # LogInformation con concatenación
        @{
            Pattern = '(LogInformation|LogError|LogWarning|LogDebug|LogTrace)\("([^"]+)"\s*\+\s*([^)]+)\)'
            Replacement = '$1("$2{Value}", $3)'
        },
        # LogInformation con interpolación $""
        @{
            Pattern = '(LogInformation|LogError|LogWarning|LogDebug|LogTrace)\(\$"([^"]*\{[^}]+\}[^"]*)"\)'
            Replacement = '$1("$2")'  # Dejar como está por ahora, requiere análisis manual
        }
    )
    
    # 2. CORREGIR EXCEPCIONES GENERICAS (S112) - 48 issues
    # Cambiar: throw new Exception("mensaje")
    # Por: throw new InvalidOperationException("mensaje")
    if ($contenido -match 'throw new Exception\(') {
        # Comentar para revisión manual en lugar de cambiar automáticamente
        # $contenido = $contenido -replace 'throw new Exception\(', 'throw new InvalidOperationException('
        # $cambios++
        Write-Host "  → Encontrado uso de Exception genérica (requiere revisión manual)" -ForegroundColor Magenta
    }
    
    # 3. SIMPLIFICAR EXPRESIONES BOOLEANAS (S6964) - 12 issues
    # if (value == true) → if (value)
    if ($contenido -match '\s+==\s+true\b') {
        $contenido = $contenido -replace '\s+==\s+true\b', ''
        $cambios++
        Write-Host "  ✓ Simplificadas expresiones booleanas (== true)" -ForegroundColor Green
    }
    
    # if (value == false) → if (!value)
    if ($contenido -match '\s+==\s+false\b') {
        $contenido = $contenido -replace '(\w+)\s+==\s+false\b', '!$1'
        $cambios++
        Write-Host "  ✓ Simplificadas expresiones booleanas (== false)" -ForegroundColor Green
    }
    
    # if (value != false) → if (value)
    if ($contenido -match '\s+!=\s+false\b') {
        $contenido = $contenido -replace '\s+!=\s+false\b', ''
        $cambios++
        Write-Host "  ✓ Simplificadas expresiones booleanas (!= false)" -ForegroundColor Green
    }
    
    # variable = condition ? true : false → variable = condition
    if ($contenido -match '\?\s*true\s*:\s*false') {
        $contenido = $contenido -replace '([^=]+)=\s*([^?]+)\?\s*true\s*:\s*false', '$1= $2'
        $cambios++
        Write-Host "  ✓ Simplificado operador ternario innecesario" -ForegroundColor Green
    }
    
    # 4. LIMPIAR CAMPOS NO USADOS
    # Buscar private readonly fields que no se usan
    # (Esto es complejo, mejor dejarlo para revisión manual)
    
    # Si hubo cambios, guardar el archivo
    if ($contenido -ne $contenidoOriginal) {
        $contenido | Set-Content $archivo.FullName -NoNewline
        $archivosModificados++
        Write-Host "  ✓ Archivo modificado ($cambios correcciones)" -ForegroundColor Green
    } else {
        Write-Host "  - Sin cambios automáticos" -ForegroundColor Gray
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archivos procesados: $($archivos.Count)" -ForegroundColor White
Write-Host "Archivos modificados: $archivosModificados" -ForegroundColor Green
Write-Host "Backup guardado en: $backupFolder" -ForegroundColor Yellow
Write-Host ""
Write-Host "SIGUIENTE PASO:" -ForegroundColor Cyan
Write-Host "Ejecuta el script de corrección manual para los issues restantes" -ForegroundColor White
Write-Host ""
