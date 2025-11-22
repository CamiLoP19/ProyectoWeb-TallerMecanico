# Instrucciones para Capturas de Pantalla - Métricas de Software

Este documento guía la captura de pantallas necesarias para completar la documentación de métricas del software.

## 📁 Preparación

1. Crear carpeta para evidencias:
   ```powershell
   New-Item -Path "c:\Users\janer\ProyectoWeb\evidencias_metricas" -ItemType Directory -Force
   ```

2. Asegurarse de tener acceso a:
   - Terminal PowerShell
   - Navegador web con acceso a SonarCloud
   - Tu cuenta de GitHub conectada a SonarCloud

---

## 📸 Capturas Requeridas

### 1. PowerShell - Conteo de Líneas de Código

**Archivo**: `evidencias_metricas/powershell_loc.png`

**Pasos**:
1. Abrir PowerShell como Administrador
2. Navegar al directorio del proyecto:
   ```powershell
   cd c:\Users\janer\ProyectoWeb\ProyectoWeb
   ```

3. Ejecutar comando de conteo:
   ```powershell
   Get-ChildItem -Include *.cs,*.razor,*.cshtml,*.css,*.js -Recurse | Get-Content | Measure-Object -Line
   ```

4. Capturar pantalla mostrando:
   - El comando ejecutado
   - El resultado con "Lines" = 34883
   - La ruta del directorio visible en el prompt

5. Guardar captura como: `evidencias_metricas/powershell_loc.png`

**Resultado esperado**:
```
Lines Words Characters Property
----- ----- ---------- --------
34883
```

---

### 2. PowerShell - Desglose por Tipo de Archivo

**Archivo**: `evidencias_metricas/powershell_desglose.png`

**Pasos**:
1. En la misma terminal PowerShell, ejecutar:
   ```powershell
   Write-Host "`nDESGLOSE POR TIPO DE ARCHIVO" -ForegroundColor Cyan
   Write-Host "============================`n" -ForegroundColor Cyan
   
   $cs = (Get-ChildItem -Filter *.cs -Recurse | Get-Content | Measure-Object -Line).Lines
   $razor = (Get-ChildItem -Filter *.razor -Recurse | Get-Content | Measure-Object -Line).Lines
   $cshtml = (Get-ChildItem -Filter *.cshtml -Recurse | Get-Content | Measure-Object -Line).Lines
   $css = (Get-ChildItem -Filter *.css -Recurse | Get-Content | Measure-Object -Line).Lines
   $js = (Get-ChildItem -Filter *.js -Recurse | Get-Content | Measure-Object -Line).Lines
   $total = $cs + $razor + $cshtml + $css + $js
   
   Write-Host "Archivos C#:     $cs líneas ($('{0:P2}' -f ($cs/$total)))" -ForegroundColor Green
   Write-Host "Archivos Razor:  $razor líneas ($('{0:P2}' -f ($razor/$total)))" -ForegroundColor Yellow
   Write-Host "Archivos CSHTML: $cshtml líneas ($('{0:P2}' -f ($cshtml/$total)))" -ForegroundColor Magenta
   Write-Host "Archivos CSS:    $css líneas ($('{0:P2}' -f ($css/$total)))" -ForegroundColor Blue
   Write-Host "Archivos JS:     $js líneas ($('{0:P2}' -f ($js/$total)))" -ForegroundColor Red
   Write-Host "`nTOTAL:           $total líneas" -ForegroundColor White -BackgroundColor DarkGreen
   ```

2. Capturar la pantalla mostrando el desglose completo con colores

3. Guardar como: `evidencias_metricas/powershell_desglose.png`

---

### 3. SonarCloud - Dashboard Principal

**Archivo**: `evidencias_metricas/sonarcloud_dashboard.png`

**Pasos**:
1. Abrir navegador y navegar a:
   ```
   https://sonarcloud.io/project/overview?id=CamiLoP19_ProyectoWeb-TallerMecanico
   ```

2. Asegurarse de estar en la pestaña **"Overview"**

3. Esperar a que carguen todas las métricas

4. Capturar pantalla completa mostrando:
   - **Quality Gate**: PASSED (en verde)
   - **Bugs**: 0
   - **Vulnerabilities**: 0  
   - **Security Hotspots**: 5 (100% reviewed)
   - **Code Smells**: 0
   - **Coverage**: N/A
   - **Duplications**: 0.0%
   - **Lines of Code**: 3862

5. Guardar como: `evidencias_metricas/sonarcloud_dashboard.png`

---

### 4. SonarCloud - Métricas de Tamaño

**Archivo**: `evidencias_metricas/sonarcloud_size.png`

**Pasos**:
1. En el mismo dashboard de SonarCloud, hacer scroll hacia abajo

2. Localizar la sección **"Size"** o **"Measures"**

3. Capturar el panel mostrando:
   - Lines of Code: 3,862
   - Statements
   - Functions: 178
   - Classes: 32
   - Files: 60

4. Guardar como: `evidencias_metricas/sonarcloud_size.png`

---

### 5. SonarCloud - Desglose por Lenguaje

**Archivo**: `evidencias_metricas/sonarcloud_languages.png`

**Pasos**:
1. En el dashboard, localizar sección **"Languages"** o **"Code"**

2. Capturar el gráfico circular o barras mostrando:
   - C#: 84.3% (3,256 LOC)
   - CSS: 6.7% (260 LOC)
   - JavaScript: 4.0% (153 LOC)
   - HTML/Razor: 5.0% (193 LOC)

3. Guardar como: `evidencias_metricas/sonarcloud_languages.png`

---

### 6. SonarCloud - Evolución Temporal (Activity)

**Archivo**: `evidencias_metricas/sonarcloud_evolution.png`

**Pasos**:
1. Navegar a la pestaña **"Activity"**:
   ```
   https://sonarcloud.io/project/activity?id=CamiLoP19_ProyectoWeb-TallerMecanico
   ```

2. Ajustar filtro de tiempo para mostrar últimos 30 días

3. Capturar gráfico mostrando evolución de:
   - Bugs: 3 → 0
   - Vulnerabilities: 72 → 0
   - Code Smells: 269 → 0
   - Technical Debt: 4d 2h → 0min

4. Asegurarse de que se vean las fechas de los commits

5. Guardar como: `evidencias_metricas/sonarcloud_evolution.png`

---

### 7. SonarCloud - Issues Resueltos

**Archivo**: `evidencias_metricas/sonarcloud_issues.png`

**Pasos**:
1. Navegar a la pestaña **"Issues"**

2. Cambiar filtro de "Open" a **"Closed"** o **"Resolved"**

3. Capturar mostrando la lista de issues corregidos:
   - Total issues resueltos: ~344
   - Filtros aplicados
   - Ejemplos de issues (S5145, S2139, S1244, etc.)

4. Guardar como: `evidencias_metricas/sonarcloud_issues.png`

---

### 8. SonarCloud - Quality Gate Passed

**Archivo**: `evidencias_metricas/sonarcloud_quality_gate.png`

**Pasos**:
1. En el dashboard principal, hacer clic en el badge **"PASSED"** del Quality Gate

2. Se abrirá un modal/página mostrando todas las condiciones

3. Capturar mostrando todos los checks en verde (✓):
   - Reliability Rating is A
   - Security Rating is A
   - Maintainability Rating is A
   - Coverage is N/A
   - Duplicated Lines <= 3.0%

4. Guardar como: `evidencias_metricas/sonarcloud_quality_gate.png`

---

### 9. SonarCloud - Security Analysis

**Archivo**: `evidencias_metricas/sonarcloud_security.png`

**Pasos**:
1. Navegar a pestaña **"Security"** o **"Security Hotspots"**

2. Capturar mostrando:
   - Security Rating: A
   - Vulnerabilities: 0
   - Security Hotspots: 5 (100% reviewed)
   - Hotspots breakdown (2 reviewed as safe)

3. Guardar como: `evidencias_metricas/sonarcloud_security.png`

---

## ✅ Verificación Final

Después de capturar todas las imágenes, verificar que existen:

```powershell
cd c:\Users\janer\ProyectoWeb\evidencias_metricas
Get-ChildItem *.png | Select-Object Name
```

**Archivos esperados** (mínimo requerido):
- ✅ `powershell_loc.png`
- ✅ `powershell_desglose.png`
- ✅ `sonarcloud_dashboard.png`
- ✅ `sonarcloud_size.png`
- ✅ `sonarcloud_languages.png`

**Archivos opcionales** (complementan la documentación):
- `sonarcloud_evolution.png`
- `sonarcloud_issues.png`
- `sonarcloud_quality_gate.png`
- `sonarcloud_security.png`

---

## 📝 Tips para Capturas de Calidad

1. **Resolución**: Capturar en resolución nativa (no zoom navegador)
2. **Recorte**: Eliminar barras de navegación/dirección innecesarias
3. **Claridad**: Asegurarse de que todos los números sean legibles
4. **Formato**: Guardar como PNG (mejor calidad que JPG)
5. **Nombres**: Usar exactamente los nombres especificados
6. **Contexto**: Incluir títulos/encabezados que den contexto

---

## 🔄 Integración con Documento

Una vez capturadas las imágenes, el documento `III_MEDICION_SOFTWARE.md` ya tiene las referencias a estas imágenes en las secciones correspondientes:

- Figura 1: PowerShell LOC → Sección 3.2.1.a
- Figura 2: SonarCloud Size → Sección 3.2.1.b
- Figura 3: SonarCloud Languages → Sección 3.2.1.b

Las imágenes se mostrarán automáticamente si están en la ruta correcta.

---

## 📧 Soporte

Si tienes problemas accediendo a SonarCloud:
1. Verificar conexión a internet
2. Verificar que el proyecto esté público en SonarCloud
3. Alternativamente, usar los datos numéricos en el documento (son suficientes)

---

**Última actualización**: 14 de Noviembre de 2025  
**Responsable**: Equipo de Desarrollo - Proyecto Taller Mecánico
