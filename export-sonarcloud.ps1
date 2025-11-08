# Script para exportar métricas y issues de SonarCloud
# Requiere tu token de SonarCloud

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [string]$ProjectKey = "CamiLoP19_ProyectoWeb-TallerMecanico",
    [string]$Organization = "camilop19"
)

$baseUrl = "https://sonarcloud.io/api"
$headers = @{
    Authorization = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Token}:")))"
}

Write-Host "=== EXPORTANDO DATOS DE SONARCLOUD ===" -ForegroundColor Cyan
Write-Host ""

# Crear carpeta para los reportes
$reportFolder = ".\SonarCloud_Reports"
if (!(Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
}

try {
    # 1. Obtener métricas generales
    Write-Host "Descargando métricas generales..." -ForegroundColor Yellow
    $metricsUrl = "$baseUrl/measures/component?component=$ProjectKey" + "&metricKeys=ncloc,bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,security_hotspots"
    $metrics = Invoke-RestMethod -Uri $metricsUrl -Headers $headers -Method Get
    $metrics | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\metricas_generales.json"
    Write-Host "✓ Métricas guardadas en metricas_generales.json" -ForegroundColor Green

    # 2. Obtener issues de seguridad
    Write-Host "Descargando issues de seguridad..." -ForegroundColor Yellow
    $securityUrl = "$baseUrl/issues/search?componentKeys=$ProjectKey" + "&types=VULNERABILITY&ps=500"
    $security = Invoke-RestMethod -Uri $securityUrl -Headers $headers -Method Get
    $security | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_seguridad.json"
    Write-Host "✓ Issues de seguridad guardados (Total: $($security.total))" -ForegroundColor Green

    # 3. Obtener bugs
    Write-Host "Descargando bugs..." -ForegroundColor Yellow
    $bugsUrl = "$baseUrl/issues/search?componentKeys=$ProjectKey" + "&types=BUG&ps=500"
    $bugs = Invoke-RestMethod -Uri $bugsUrl -Headers $headers -Method Get
    $bugs | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_bugs.json"
    Write-Host "✓ Bugs guardados (Total: $($bugs.total))" -ForegroundColor Green

    # 4. Obtener code smells
    Write-Host "Descargando code smells..." -ForegroundColor Yellow
    $smellsUrl = "$baseUrl/issues/search?componentKeys=$ProjectKey" + "&types=CODE_SMELL&ps=500"
    $smells = Invoke-RestMethod -Uri $smellsUrl -Headers $headers -Method Get
    $smells | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_code_smells.json"
    Write-Host "✓ Code smells guardados (Total: $($smells.total))" -ForegroundColor Green

    # 5. Obtener hotspots de seguridad
    Write-Host "Descargando security hotspots..." -ForegroundColor Yellow
    $hotspotsUrl = "$baseUrl/hotspots/search?projectKey=$ProjectKey" + "&ps=500"
    $hotspots = Invoke-RestMethod -Uri $hotspotsUrl -Headers $headers -Method Get
    $hotspots | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\security_hotspots.json"
    Write-Host "✓ Security hotspots guardados (Total: $($hotspots.paging.total))" -ForegroundColor Green

    # 6. Crear resumen en Markdown
    Write-Host ""
    Write-Host "Generando resumen en Markdown..." -ForegroundColor Yellow
    
    $markdown = @"
# Reporte SonarCloud - ProyectoWeb Taller Mecanico
**Fecha**: $(Get-Date -Format "dd/MM/yyyy HH:mm")
**Proyecto**: $ProjectKey
**Organizacion**: $Organization

## Resumen de Metricas

"@
    
    foreach ($measure in $metrics.component.measures) {
        $markdown += "- **$($measure.metric)**: $($measure.value)`n"
    }
    
    $markdown += @"

## Issues Detectados

### Resumen
- **Vulnerabilidades**: $($security.total)
- **Bugs**: $($bugs.total)
- **Code Smells**: $($smells.total)
- **Security Hotspots**: $($hotspots.paging.total)

### Top 10 Issues de Seguridad
$(if ($security.issues.Count -gt 0) {
    for ($i = 0; $i -lt [Math]::Min(10, $security.issues.Count); $i++) {
        $issue = $security.issues[$i]
        "
#### $($i+1). $($issue.message)
- **Archivo**: ``$($issue.component -replace '.*:', '')``
- **Línea**: $($issue.line)
- **Severidad**: $($issue.severity)
- **Regla**: $($issue.rule)
"
    }
} else {
    "No se encontraron issues de seguridad."
})

### Top 10 Bugs
$(if ($bugs.issues.Count -gt 0) {
    for ($i = 0; $i -lt [Math]::Min(10, $bugs.issues.Count); $i++) {
        $issue = $bugs.issues[$i]
        "
#### $($i+1). $($issue.message)
- **Archivo**: ``$($issue.component -replace '.*:', '')``
- **Línea**: $($issue.line)
- **Severidad**: $($issue.severity)
- **Regla**: $($issue.rule)
"
    }
} else {
    "No se encontraron bugs."
})

### Top 10 Code Smells Críticos
$(if ($smells.issues.Count -gt 0) {
    $criticalSmells = $smells.issues | Where-Object { $_.severity -eq "CRITICAL" -or $_.severity -eq "MAJOR" } | Select-Object -First 10
    if ($criticalSmells.Count -gt 0) {
        for ($i = 0; $i -lt $criticalSmells.Count; $i++) {
            $issue = $criticalSmells[$i]
            "
#### $($i+1). $($issue.message)
- **Archivo**: ``$($issue.component -replace '.*:', '')``
- **Línea**: $($issue.line)
- **Severidad**: $($issue.severity)
- **Regla**: $($issue.rule)
"
        }
    } else {
        "No se encontraron code smells críticos."
    }
} else {
    "No se encontraron code smells."
})

## Acciones Recomendadas

### Prioridad Alta
1. Corregir las vulnerabilidades de seguridad detectadas
2. Resolver los bugs que afectan la funcionalidad
3. Revisar los security hotspots críticos

### Prioridad Media
4. Refactorizar code smells con severidad alta/media
5. Mejorar la cobertura de código con pruebas unitarias
6. Reducir duplicación de código si existe

---

**Archivos generados**:
- metricas_generales.json
- issues_seguridad.json
- issues_bugs.json
- issues_code_smells.json
- security_hotspots.json
"@

    $markdown | Out-File "$reportFolder\REPORTE_COMPLETO.md" -Encoding UTF8
    Write-Host "✓ Resumen guardado en REPORTE_COMPLETO.md" -ForegroundColor Green

    # 7. Crear archivo CSV con todos los issues
    Write-Host ""
    Write-Host "Generando archivo CSV con todos los issues..." -ForegroundColor Yellow
    
    $allIssues = @()
    
    foreach ($issue in $security.issues) {
        $allIssues += [PSCustomObject]@{
            Tipo = "VULNERABILITY"
            Mensaje = $issue.message
            Archivo = $issue.component -replace '.*:', ''
            Linea = $issue.line
            Severidad = $issue.severity
            Estado = $issue.status
            Regla = $issue.rule
        }
    }
    
    foreach ($issue in $bugs.issues) {
        $allIssues += [PSCustomObject]@{
            Tipo = "BUG"
            Mensaje = $issue.message
            Archivo = $issue.component -replace '.*:', ''
            Linea = $issue.line
            Severidad = $issue.severity
            Estado = $issue.status
            Regla = $issue.rule
        }
    }
    
    foreach ($issue in $smells.issues) {
        $allIssues += [PSCustomObject]@{
            Tipo = "CODE_SMELL"
            Mensaje = $issue.message
            Archivo = $issue.component -replace '.*:', ''
            Linea = $issue.line
            Severidad = $issue.severity
            Estado = $issue.status
            Regla = $issue.rule
        }
    }
    
    $allIssues | Export-Csv "$reportFolder\todos_los_issues.csv" -NoTypeInformation -Encoding UTF8
    Write-Host "✓ CSV generado con $($allIssues.Count) issues totales" -ForegroundColor Green

    Write-Host ""
    Write-Host "=== EXPORTACIÓN COMPLETADA ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Archivos generados en: $reportFolder" -ForegroundColor Green
    Write-Host "- REPORTE_COMPLETO.md (Para leer fácilmente)" -ForegroundColor White
    Write-Host "- todos_los_issues.csv (Para Excel)" -ForegroundColor White
    Write-Host "- *.json (Datos completos en JSON)" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrate de:" -ForegroundColor Yellow
    Write-Host "1. Tener un token válido de SonarCloud" -ForegroundColor Yellow
    Write-Host "2. El ProjectKey y Organization sean correctos" -ForegroundColor Yellow
    Write-Host "3. Tener permisos de lectura en el proyecto" -ForegroundColor Yellow
}
