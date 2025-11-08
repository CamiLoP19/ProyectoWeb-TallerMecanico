# Script para eliminar comentarios de archivos C# y Razor
# USO: .\remove-comments.ps1

Write-Host "=== ELIMINADOR DE COMENTARIOS ===" -ForegroundColor Cyan
Write-Host "ADVERTENCIA: Esto modificará los archivos originales!" -ForegroundColor Red
Write-Host "Se recomienda hacer un commit en Git antes de ejecutar." -ForegroundColor Yellow
Write-Host ""

$respuesta = Read-Host "¿Deseas continuar? (si/no)"

if ($respuesta -ne "si") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit
}

# Obtener todos los archivos .cs (excluyendo obj y bin)
$archivos = Get-ChildItem -Path ".\ProyectoWeb" -Recurse -Include *.cs,*.razor | 
    Where-Object { $_.FullName -notmatch "\\obj\\" -and $_.FullName -notmatch "\\bin\\" }

$contador = 0

foreach ($archivo in $archivos) {
    Write-Host "Procesando: $($archivo.Name)" -ForegroundColor Green
    
    $contenido = Get-Content $archivo.FullName -Raw
    
    # Eliminar comentarios de una línea //
    $contenido = $contenido -replace '(?m)^\s*//.*$', ''
    
    # Eliminar comentarios de múltiples líneas /* */
    $contenido = $contenido -replace '/\*[\s\S]*?\*/', ''
    
    # Eliminar líneas vacías múltiples (dejar solo una)
    $contenido = $contenido -replace '(?m)^\s*$\n', ''
    
    # Guardar el archivo modificado
    $contenido | Set-Content $archivo.FullName -NoNewline
    
    $contador++
}

Write-Host ""
Write-Host "=== PROCESO COMPLETADO ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $contador" -ForegroundColor Green
Write-Host ""
Write-Host "NOTA: Revisa los cambios con 'git diff' antes de hacer commit" -ForegroundColor Yellow
