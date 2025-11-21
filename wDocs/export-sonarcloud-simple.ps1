# Script simplificado para exportar métricas de SonarCloud
param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [string]$ProjectKey = "CamiLoP19_ProyectoWeb-TallerMecanico",
    [string]$Organization = "camilop19"
)

$baseUrl = "https://sonarcloud.io/api"
$authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Token}:"))

Write-Host "=== EXPORTANDO DATOS DE SONARCLOUD ===" -ForegroundColor Cyan
Write-Host ""

# Crear carpeta para los reportes
$reportFolder = ".\SonarCloud_Reports"
if (!(Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
}

try {
    # 1. Métricas generales
    Write-Host "Descargando métricas generales..." -ForegroundColor Yellow
    $metricsUrl = "${baseUrl}/measures/component?component=${ProjectKey}&metricKeys=ncloc,bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,security_hotspots"
    $metrics = Invoke-RestMethod -Uri $metricsUrl -Headers @{Authorization=$authHeader} -Method Get
    $metrics | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\metricas_generales.json"
    Write-Host "  Guardado: metricas_generales.json" -ForegroundColor Green

    # 2. Issues de seguridad
    Write-Host "Descargando vulnerabilidades..." -ForegroundColor Yellow
    $securityUrl = "${baseUrl}/issues/search?componentKeys=${ProjectKey}&types=VULNERABILITY&ps=500"
    $security = Invoke-RestMethod -Uri $securityUrl -Headers @{Authorization=$authHeader} -Method Get
    $security | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_seguridad.json"
    Write-Host "  Total vulnerabilidades: $($security.total)" -ForegroundColor Green

    # 3. Bugs
    Write-Host "Descargando bugs..." -ForegroundColor Yellow
    $bugsUrl = "${baseUrl}/issues/search?componentKeys=${ProjectKey}&types=BUG&ps=500"
    $bugs = Invoke-RestMethod -Uri $bugsUrl -Headers @{Authorization=$authHeader} -Method Get
    $bugs | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_bugs.json"
    Write-Host "  Total bugs: $($bugs.total)" -ForegroundColor Green

    # 4. Code Smells
    Write-Host "Descargando code smells..." -ForegroundColor Yellow
    $smellsUrl = "${baseUrl}/issues/search?componentKeys=${ProjectKey}&types=CODE_SMELL&ps=500"
    $smells = Invoke-RestMethod -Uri $smellsUrl -Headers @{Authorization=$authHeader} -Method Get
    $smells | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\issues_code_smells.json"
    Write-Host "  Total code smells: $($smells.total)" -ForegroundColor Green

    # 5. Security Hotspots
    Write-Host "Descargando security hotspots..." -ForegroundColor Yellow
    $hotspotsUrl = "${baseUrl}/hotspots/search?projectKey=${ProjectKey}&ps=500"
    $hotspots = Invoke-RestMethod -Uri $hotspotsUrl -Headers @{Authorization=$authHeader} -Method Get
    $hotspots | ConvertTo-Json -Depth 10 | Out-File "$reportFolder\security_hotspots.json"
    Write-Host "  Total hotspots: $($hotspots.paging.total)" -ForegroundColor Green

    # 6. Crear CSV con todos los issues
    Write-Host ""
    Write-Host "Generando archivo CSV..." -ForegroundColor Yellow
    
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
    Write-Host "  CSV generado con $($allIssues.Count) issues" -ForegroundColor Green

    # 7. Crear resumen en texto
    Write-Host ""
    Write-Host "Generando resumen..." -ForegroundColor Yellow
    
    $resumen = @"
REPORTE SONARCLOUD - PROYECTOWEB TALLER MECANICO
=================================================

Fecha: $(Get-Date -Format "dd/MM/yyyy HH:mm")
Proyecto: $ProjectKey
Organizacion: $Organization

METRICAS GENERALES
------------------
"@

    foreach ($measure in $metrics.component.measures) {
        $resumen += "`n$($measure.metric): $($measure.value)"
    }
    
    $resumen += @"


ISSUES DETECTADOS
-----------------
Vulnerabilidades: $($security.total)
Bugs: $($bugs.total)
Code Smells: $($smells.total)
Security Hotspots: $($hotspots.paging.total)

ARCHIVOS GENERADOS
------------------
- metricas_generales.json
- issues_seguridad.json
- issues_bugs.json
- issues_code_smells.json
- security_hotspots.json
- todos_los_issues.csv
"@

    $resumen | Out-File "$reportFolder\RESUMEN.txt" -Encoding UTF8
    Write-Host "  Resumen guardado en RESUMEN.txt" -ForegroundColor Green

    Write-Host ""
    Write-Host "=== EXPORTACION COMPLETADA ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Archivos generados en: $reportFolder" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
}
