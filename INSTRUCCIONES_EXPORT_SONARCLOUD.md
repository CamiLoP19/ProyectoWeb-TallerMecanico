# Instrucciones para Exportar Datos de SonarCloud

## Opción 1: Descargar PDF desde SonarCloud (MÁS FÁCIL)

1. Ve a: https://sonarcloud.io/project/overview?id=CamiLoP19_ProyectoWeb-TallerMecanico
2. Click en **"More"** (⋮ arriba a la derecha)
3. Selecciona **"Download as PDF"**
4. ¡Listo! Tendrás un PDF completo con todas las métricas

## Opción 2: Usar el Script de PowerShell (MÁS COMPLETO)

### Paso 1: Obtener Token de SonarCloud

1. Ve a: https://sonarcloud.io/account/security
2. En "Generate Tokens":
   - Name: `export-proyectoweb`
   - Type: `User Token`
   - Click "Generate"
3. **¡COPIA EL TOKEN INMEDIATAMENTE!** (solo se muestra una vez)

### Paso 2: Ejecutar el Script

```powershell
# Navega a la carpeta del proyecto
cd c:\Users\janer\ProyectoWeb

# Ejecuta el script con tu token
.\export-sonarcloud.ps1 -Token "TU_TOKEN_AQUI"
```

### Paso 3: Resultados

El script creará una carpeta `SonarCloud_Reports` con:

- ✅ **REPORTE_COMPLETO.md** - Resumen legible con todos los issues
- ✅ **todos_los_issues.csv** - Para abrir en Excel y filtrar
- ✅ **metricas_generales.json** - Métricas del proyecto
- ✅ **issues_seguridad.json** - Todas las vulnerabilidades
- ✅ **issues_bugs.json** - Todos los bugs
- ✅ **issues_code_smells.json** - Todos los problemas de código
- ✅ **security_hotspots.json** - Puntos críticos de seguridad

## Opción 3: Exportar Issues Manualmente desde Web

### Para exportar a CSV:

1. Ve a: https://sonarcloud.io/project/issues?id=CamiLoP19_ProyectoWeb-TallerMecanico
2. Filtra por tipo de issue (Bug, Vulnerability, Code Smell)
3. Click en el botón de descarga (si está disponible)

### Capturas de pantalla útiles:

**Dashboard Principal:**
- https://sonarcloud.io/summary/overall?id=CamiLoP19_ProyectoWeb-TallerMecanico

**Vista de Issues:**
- https://sonarcloud.io/project/issues?id=CamiLoP19_ProyectoWeb-TallerMecanico

**Security Hotspots:**
- https://sonarcloud.io/project/security_hotspots?id=CamiLoP19_ProyectoWeb-TallerMecanico

**Medidas:**
- https://sonarcloud.io/component_measures?id=CamiLoP19_ProyectoWeb-TallerMecanico

## Recomendación

Para tu trabajo universitario:

1. **Descarga el PDF** (Opción 1) - Es oficial y tiene buen formato
2. **Ejecuta el script** (Opción 2) - Para tener datos en Excel y analizarlos
3. **Toma capturas de pantalla** de las secciones importantes

## Notas de Seguridad

⚠️ **IMPORTANTE**: 
- NO compartas tu token de SonarCloud
- NO subas el token a GitHub
- El token da acceso de lectura a tus proyectos
