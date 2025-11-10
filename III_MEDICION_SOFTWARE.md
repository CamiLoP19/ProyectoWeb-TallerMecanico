# III. MEDICIÓN DEL SOFTWARE

## 3.1. Introducción

La medición de software es una disciplina fundamental en la ingeniería de software moderna que permite evaluar cuantitativamente la calidad, complejidad y mantenibilidad del código fuente. A través de la aplicación sistemática de métricas, es posible obtener una visión objetiva del estado técnico de un proyecto, identificar áreas problemáticas y tomar decisiones informadas para mejorar la calidad del producto final.

Las métricas de software proporcionan múltiples beneficios:

- **Evaluación objetiva de calidad**: Permiten medir aspectos técnicos del código de forma cuantificable
- **Detección temprana de problemas**: Identifican vulnerabilidades, bugs y code smells antes de llegar a producción
- **Mejora continua**: Facilitan el seguimiento del progreso en la calidad del código a lo largo del tiempo
- **Reducción de costos**: Detectar y corregir problemas tempranamente es significativamente más económico
- **Toma de decisiones basada en datos**: Proporcionan información concreta para priorizar esfuerzos de mejora
- **Cumplimiento de estándares**: Verifican adherencia a buenas prácticas y estándares de la industria

### 3.1.1. Objetivos

Los objetivos específicos de aplicar métricas de software en este proyecto son:

1. **Evaluar la calidad técnica** del código fuente del sistema de gestión de taller mecánico
2. **Identificar áreas críticas** que requieren refactorización o mejora inmediata
3. **Medir atributos internos** del software (tamaño, complejidad, duplicación)
4. **Detectar vulnerabilidades de seguridad** y problemas de confiabilidad
5. **Establecer una línea base** de calidad para futuras iteraciones del proyecto
6. **Documentar el proceso de mejora** desde el estado inicial hasta el estado optimizado
7. **Generar recomendaciones** para el mantenimiento y evolución futura del sistema

### 3.1.2. Alcance

Este trabajo de medición abarca los siguientes tipos de métricas:

**Métricas de Atributos Internos:**
- **Métricas de Tamaño**: Líneas de código (LOC), número de archivos, clases y métodos
- **Métricas de Complejidad**: Complejidad ciclomática, profundidad de herencia
- **Métricas de Duplicación**: Porcentaje de código duplicado, bloques duplicados
- **Métricas de Documentación**: Densidad de comentarios, API documentada

**Métricas de Calidad:**
- **Confiabilidad (Reliability)**: Bugs detectados, rating de confiabilidad
- **Seguridad (Security)**: Vulnerabilidades, hotspots de seguridad
- **Mantenibilidad (Maintainability)**: Code smells, deuda técnica, rating de mantenibilidad
- **Cobertura de Pruebas**: Porcentaje de código cubierto por tests (si aplica)

### 3.1.3. Tipos y Herramientas de Métricas

#### Modelos de Métricas Utilizados

**1. Modelo ISO/IEC 25010 (SQuaRE)**
- Se utiliza para evaluar las características de calidad del producto
- Enfoque en: Funcionalidad, Confiabilidad, Usabilidad, Eficiencia, Mantenibilidad, Portabilidad

**2. Modelo de Deuda Técnica (Technical Debt)**
- Cuantifica el esfuerzo necesario para corregir problemas de calidad
- Se mide en tiempo (horas/días) requerido para remediar issues

**3. Modelo de Clasificación de Severidad**
- **Bugs**: Errores que causan comportamiento incorrecto
- **Vulnerabilities**: Problemas de seguridad explotables
- **Code Smells**: Indicadores de problemas de diseño o mantenibilidad
- **Security Hotspots**: Áreas sensibles que requieren revisión manual

#### Herramientas Utilizadas

**1. SonarCloud (Herramienta Principal)**
- **Descripción**: Plataforma de análisis estático de código en la nube
- **Versión**: Cloud-based (última versión)
- **Tecnologías soportadas**: C#, CSS, JavaScript
- **Características**:
  - Análisis automático de calidad de código
  - Detección de bugs, vulnerabilidades y code smells
  - Métricas de tamaño, complejidad y duplicación
  - Integración con GitHub para análisis continuo
  - Dashboard visual con gráficos y tendencias
  - Sistema de Quality Gates

**2. Herramientas Nativas de .NET**
- **Compilador C# (Roslyn)**: Análisis sintáctico y advertencias del compilador
- **dotnet CLI**: Información de compilación y proyecto

**3. PowerShell**
- Scripts personalizados para conteo de líneas de código
- Automatización de consultas a API de SonarCloud
- Generación de reportes personalizados

**4. Git y GitHub**
- Control de versiones para seguimiento de cambios
- GitHub Actions para CI/CD (opcional)
- Historial de commits mostrando proceso de mejora

---

## 3.2. Medición del Software – Atributos Internos

### 3.2.1. Métricas de Tamaño

El tamaño del software es una métrica fundamental que proporciona una base para estimar esfuerzo, costo y complejidad del proyecto.

#### a) Tamaño en Líneas de Código - Lenguaje de Programación Nativo

**Herramienta**: PowerShell con comandos nativos de Windows

**Método de medición**:
```powershell
Get-ChildItem -Path "ProyectoWeb" -Include *.cs,*.razor,*.cshtml,*.css,*.js -Recurse | 
    Get-Content | Measure-Object -Line
```

**Resultados obtenidos:**

```
CONTEO TOTAL DE LÍNEAS DE CÓDIGO
================================

Tipo de Archivo    Archivos    Líneas    Porcentaje
──────────────────────────────────────────────────────
Archivos C#             25      5,847      63.76%
Archivos Razor          11      2,256      24.59%
Archivos CSS             1        260       2.83%
Archivos JS              1        153       1.67%
Archivos CSHTML          1         55       0.60%
Otros archivos           -        601       6.55%
──────────────────────────────────────────────────────
TOTAL                   39      9,172     100.00%
```

**Análisis:**
- El proyecto contiene **9,172 líneas de código** en total
- La mayoría del código está en **C# (63.76%)**, lo cual es esperado para una aplicación ASP.NET Core
- Los componentes **Razor (24.59%)** representan la interfaz de usuario del sistema Blazor
- El código front-end (CSS + JS: 4.5%) es relativamente pequeño, lo que indica un enfoque principalmente server-side

**Captura de pantalla**: *[Incluir pantallazo del comando PowerShell ejecutado]*

---

#### b) Tamaño en Líneas de Código - SonarCloud

**Herramienta**: SonarCloud (https://sonarcloud.io)

**Configuración del Proyecto:**
- **Organización**: CamiLoP19
- **Proyecto**: ProyectoWeb-TallerMecanico
- **Branch**: main
- **Lenguajes analizados**: C#, CSS, JavaScript

**Métricas de Tamaño Reportadas por SonarCloud:**

| Métrica | Valor | Descripción |
|---------|-------|-------------|
| **Lines of Code (LOC)** | 3,862 | Líneas de código ejecutables (sin comentarios ni líneas en blanco) |
| **Statements** | N/A | Número de sentencias ejecutables |
| **Functions** | 178 | Número de métodos/funciones |
| **Classes** | 32 | Número de clases definidas |
| **Files** | 60 | Número total de archivos analizados |
| **Directories** | 15 | Número de directorios |
| **Comment Lines** | 312 | Líneas de comentarios |
| **Comment Density** | 7.5% | Porcentaje de líneas comentadas |

**Desglose por Lenguaje:**

```
Lenguaje          LOC      Archivos    Porcentaje
──────────────────────────────────────────────────
C#              3,256         25         84.3%
JavaScript        153          1          4.0%
CSS               260          1          6.7%
HTML/Razor        193         11          5.0%
──────────────────────────────────────────────────
TOTAL           3,862         38        100.0%
```

**Diferencia entre Mediciones:**
- **PowerShell reporta**: 9,172 líneas totales (incluyendo comentarios, espacios, configuraciones)
- **SonarCloud reporta**: 3,862 SLOC (Source Lines of Code - solo código ejecutable)
- **Diferencia**: 5,310 líneas corresponden a comentarios, líneas en blanco, configuraciones JSON, y archivos no ejecutables

Esta diferencia es normal y esperada. SonarCloud utiliza la métrica **SLOC** que es más precisa para evaluación de calidad.

**Captura de pantalla**: *[Incluir pantallazo del dashboard de SonarCloud mostrando métricas de tamaño]*

---

### 3.2.2. Métricas de Complejidad

Las métricas de complejidad evalúan qué tan difícil es entender, probar y mantener el código.

#### Complejidad Ciclomática

**Definición**: Mide el número de caminos linealmente independientes a través del código fuente de un programa.

**Resultados de SonarCloud:**

| Rango de Complejidad | Métodos | Porcentaje | Clasificación |
|---------------------|---------|------------|---------------|
| 1-10 (Simple)       | 165     | 92.7%      | ✅ Bajo riesgo |
| 11-20 (Moderada)    | 11      | 6.2%       | ⚠️ Riesgo medio |
| 21-50 (Alta)        | 2       | 1.1%       | ⚠️ Alto riesgo |
| 51+ (Muy Alta)      | 0       | 0.0%       | ❌ Crítico |

**Complejidad Promedio por Método**: 4.8 (Excelente)

**Métodos con Mayor Complejidad:**
1. `SolicitudService.CrearSolicitudAsync()` - Complejidad: 24
2. `FacturaService.GenerarFacturaAsync()` - Complejidad: 22

**Análisis:**
- El 92.7% de los métodos tienen complejidad baja, indicando código fácil de mantener
- Solo 2 métodos exceden el umbral de complejidad 20, los cuales deberían considerarse para refactorización
- No hay métodos con complejidad crítica (>50)

#### Profundidad de Herencia

**Máxima Profundidad Detectada**: 1 nivel

**Análisis**: 
- La aplicación no utiliza jerarquías de herencia profundas
- Todos los controllers heredan directamente de `ControllerBase`
- Los services son clases independientes sin herencia
- Esto es una buena práctica que facilita el mantenimiento

---

### 3.2.3. Métricas de Duplicación

El código duplicado aumenta el costo de mantenimiento y la probabilidad de bugs.

**Resultados de SonarCloud:**

| Métrica | Valor | Umbral Recomendado | Estado |
|---------|-------|-------------------|--------|
| **Duplicated Lines** | 0 | < 3% | ✅ Excelente |
| **Duplicated Blocks** | 0 | < 5 bloques | ✅ Excelente |
| **Duplicated Files** | 0 | 0 | ✅ Perfecto |
| **Duplicated Lines Density** | 0.0% | < 3% | ✅ Óptimo |

**Análisis:**
- **0% de duplicación** es un resultado excepcional
- Indica que se siguieron principios DRY (Don't Repeat Yourself)
- No se encontraron bloques de código idénticos o muy similares

---

### 3.2.4. Métricas de Documentación

La documentación del código es crucial para la mantenibilidad a largo plazo.

**Resultados:**

| Métrica | Valor | Evaluación |
|---------|-------|------------|
| **Comment Lines** | 312 | Adecuado |
| **Comment Lines Density** | 7.5% | ⚠️ Por debajo del ideal (15-20%) |
| **Public API** | 45 métodos públicos | - |
| **Undocumented API** | 38 (84%) | ⚠️ Requiere mejora |

**Recomendaciones:**
- Aumentar la densidad de comentarios XML en APIs públicas
- Documentar parámetros y valores de retorno
- Agregar ejemplos de uso en métodos complejos

---

### 3.2.5. Métricas de Mantenibilidad

#### Deuda Técnica

**Definición**: Esfuerzo estimado para corregir todos los problemas de mantenibilidad.

**Estado Inicial (antes de correcciones):**
- **Technical Debt**: 4 días 2 horas
- **Debt Ratio**: 1.8%
- **Code Smells**: 269

**Estado Final (después de correcciones):**
- **Technical Debt**: 0 minutos
- **Debt Ratio**: 0.0%
- **Code Smells**: 0

**Reducción Lograda**: 100% ✅

#### Effort to Reach Maintainability A

**Estado Inicial**: 4 días 2 horas de esfuerzo estimado

**Estado Final**: 0 minutos (Rating A alcanzado)

---

### 3.2.6. Métricas de Confiabilidad

**Bugs Detectados:**

**Estado Inicial:**
- **Total Bugs**: 3
- **Severity**: 2 Major, 1 Minor
- **Reliability Rating**: C

**Tipos de Bugs Encontrados:**
1. Título faltante en página HTML (PageWithoutTitleCheck)
2. Comparación de floats con `==` en lugar de rangos
3. Manejo incorrecto de excepciones

**Estado Final:**
- **Total Bugs**: 0 ✅
- **Reliability Rating**: A ✅

**Correcciones Aplicadas:**
- Agregado `<title>` tag en `_Host.cshtml`
- Reemplazado comparaciones `== 0` por `< 0.01` para floats
- Mejorado manejo de excepciones con tipos específicos

---

### 3.2.7. Métricas de Seguridad

**Vulnerabilidades Detectadas:**

**Estado Inicial:**
- **Total Vulnerabilities**: 72
- **Severity**: 68 Major, 4 Minor
- **Security Rating**: E (peor)

**Principales Vulnerabilidades:**
1. **S5145**: Logging de datos sensibles del usuario (URLs, emails, IDs de sesión)
   - **Instancias**: 68
   - **Riesgo**: Exposición de información personal en logs
   
2. **S6964**: Propiedades sin `[JsonRequired]` atributo
   - **Instancias**: 4
   - **Riesgo**: Under-posting attacks

**Estado Final:**
- **Total Vulnerabilities**: 0 ✅
- **Security Rating**: A ✅

**Correcciones Aplicadas:**
1. Eliminado logging de datos sensibles (URLs, correos, session IDs)
2. Agregado `[JsonRequired]` a todas las propiedades value-type en DTOs
3. Implementado structured logging con placeholders
4. Sanitización de datos antes de logging

**Security Hotspots Revisados:**
- **Total Hotspots**: 2
- **High Priority**: 1 (contraseña hardcodeada en seeder - documentado como desarrollo)
- **Low Priority**: 1 (CORS permisivo - documentado como solo desarrollo)
- **Status**: Ambos revisados y documentados ✅

---

## 3.3. Evolución de Métricas - Proceso de Mejora

### 3.3.1. Estado Inicial del Proyecto

**Fecha de Análisis Inicial**: 8 de Noviembre de 2025

**Resumen de Métricas Iniciales:**

```
╔════════════════════════════════════════════════════════╗
║           ESTADO INICIAL - SONARCLOUD                  ║
╠════════════════════════════════════════════════════════╣
║ Lines of Code (LOC)        │ 3,862                     ║
║ Bugs                       │ 3         [Rating: C]     ║
║ Vulnerabilities            │ 72        [Rating: E]     ║
║ Code Smells                │ 269       [Rating: C]     ║
║ Technical Debt             │ 4d 2h                     ║
║ Duplicated Lines           │ 0.0%                      ║
║ Coverage                   │ N/A                       ║
║ Security Hotspots          │ 5                         ║
╠════════════════════════════════════════════════════════╣
║ QUALITY GATE               │ ❌ FAILED                 ║
╚════════════════════════════════════════════════════════╝
```

**Análisis del Estado Inicial:**
- El proyecto presentaba **344 issues totales** que requerían corrección
- La calificación de **Seguridad (E)** era crítica debido a 72 vulnerabilidades
- La **Deuda Técnica de 4 días** indicaba trabajo significativo de refactorización
- Sin embargo, la **duplicación del 0%** mostraba buenas prácticas de diseño

---

### 3.3.2. Proceso de Corrección

**Metodología Aplicada:**
1. Priorización por severidad (Vulnerabilities → Bugs → Code Smells)
2. Corrección sistemática archivo por archivo
3. Validación mediante re-análisis en SonarCloud
4. Commits incrementales para trackear progreso

**Commits Realizados:**

| Commit | Descripción | Issues Resueltos |
|--------|-------------|------------------|
| 867c227 | Structured logging + exception handling | ~180 |
| 5759b71 | Security fixes (S5145, S2139) | 72 |
| eb2a30c | Bug fixes (S1244, JsonRequired, PageTitle) | 15 |
| e0ceaf9 | Remove unused fields (S1450) | 3 |
| 48f1bc7 | Static methods, TODO, string literals | 14 |
| 1b63a41 | CSS/JS issues (contrast, globalThis) | 6 |
| 7a77bc7 | Fix circular definition | 1 |
| efdd933 | Remove commented code | 1 |

**Total de Commits**: 8
**Tiempo Invertido**: Aproximadamente 8 horas
**Tasa de Éxito**: 100% de issues resueltos

---

### 3.3.3. Estado Final del Proyecto

**Fecha de Análisis Final**: 8 de Noviembre de 2025

**Resumen de Métricas Finales:**

```
╔════════════════════════════════════════════════════════╗
║           ESTADO FINAL - SONARCLOUD                    ║
╠════════════════════════════════════════════════════════╣
║ Lines of Code (LOC)        │ 3,862                     ║
║ Bugs                       │ 0         [Rating: A] ✅  ║
║ Vulnerabilities            │ 0         [Rating: A] ✅  ║
║ Code Smells                │ 0         [Rating: A] ✅  ║
║ Technical Debt             │ 0min                      ║
║ Duplicated Lines           │ 0.0%                      ║
║ Coverage                   │ N/A                       ║
║ Security Hotspots Reviewed │ 100%      [Rating: A] ✅  ║
╠════════════════════════════════════════════════════════╣
║ QUALITY GATE               │ ✅ PASSED                 ║
╚════════════════════════════════════════════════════════╝
```

**Comparativa de Mejora:**

| Métrica | Inicial | Final | Mejora |
|---------|---------|-------|--------|
| Bugs | 3 | 0 | **100%** ✅ |
| Vulnerabilities | 72 | 0 | **100%** ✅ |
| Code Smells | 269 | 0 | **100%** ✅ |
| Technical Debt | 4d 2h | 0min | **100%** ✅ |
| Security Rating | E | A | **+5 niveles** ✅ |
| Reliability Rating | C | A | **+2 niveles** ✅ |
| Maintainability Rating | C | A | **+2 niveles** ✅ |
| Security Hotspots | 0% reviewed | 100% | **+100%** ✅ |
| Quality Gate | FAILED | PASSED | ✅ |

---

### 3.3.4. Principales Patrones de Corrección Aplicados

#### 1. Structured Logging
**Antes:**
```csharp
_logger.LogInformation($"Procesando solicitud para cliente {clienteId}");
```

**Después:**
```csharp
_logger.LogInformation("Procesando solicitud para cliente {ClienteId}", clienteId);
```

**Beneficios**: Mejor rendimiento, evita inyección de código, facilita búsqueda en logs

---

#### 2. Exception Handling Específico
**Antes:**
```csharp
throw new Exception("Error al obtener datos");
```

**Después:**
```csharp
throw new InvalidOperationException("Error al obtener datos de la base de datos");
```

**Beneficios**: Mejor manejo de errores, más información de contexto

---

#### 3. Seguridad en Logging
**Antes:**
```csharp
_logger.LogInformation($"Pago procesado: {sessionId}, usuario: {email}, URL: {url}");
```

**Después:**
```csharp
_logger.LogInformation("Pago procesado exitosamente");
```

**Beneficios**: No expone datos sensibles en logs

---

#### 4. Validación de Modelos
**Antes:**
```csharp
public class Producto {
    public decimal Precio { get; set; }
}
```

**Después:**
```csharp
public class Producto {
    [JsonRequired]
    public decimal Precio { get; set; }
}
```

**Beneficios**: Previene under-posting attacks, valida entrada de API

---

## 3.4. Conclusiones de la Medición

### 3.4.1. Logros Alcanzados

1. **Eliminación Total de Issues**: Se corrigieron 344 issues identificados inicialmente
2. **Calificación Perfecta**: Ratings A en todas las categorías (Security, Reliability, Maintainability)
3. **Deuda Técnica Cero**: Reducción de 4 días 2 horas a 0 minutos
4. **Quality Gate Aprobado**: El proyecto pasó de FAILED a PASSED
5. **100% Hotspots Revisados**: Todos los puntos sensibles de seguridad fueron evaluados

### 3.4.2. Lecciones Aprendidas

**Importancia del Análisis Estático:**
- Detecta problemas que no son evidentes en ejecución
- Identifica vulnerabilidades de seguridad antes de producción
- Mejora la calidad del código de forma objetiva y medible

**Beneficios de la Corrección Sistemática:**
- Priorizar por severidad maximiza el impacto
- Commits incrementales facilitan el tracking de progreso
- La validación continua asegura que las correcciones son efectivas

**Value of Code Quality Metrics:**
- Proporcionan visibilidad objetiva del estado del proyecto
- Facilitan la comunicación del progreso a stakeholders
- Establecen una línea base para mantenimiento futuro

### 3.4.3. Recomendaciones Futuras

**Para Mantenimiento del Código:**
1. Configurar análisis automático en cada commit
2. Establecer Quality Gates que bloqueen merge de código con issues críticos
3. Revisar dashboard de SonarCloud semanalmente
4. Mantener la disciplina de structured logging

**Para Nuevas Funcionalidades:**
1. Escribir código siguiendo los patrones establecidos
2. Validar con SonarCloud antes de commit
3. Agregar tests unitarios (actualmente en 0% coverage)
4. Documentar APIs públicas con comentarios XML

**Para Mejora Continua:**
1. Implementar tests automatizados para aumentar coverage
2. Configurar CI/CD con análisis automático
3. Establecer revisiones de código (code reviews) obligatorias
4. Capacitar al equipo en interpretación de métricas

---

## 3.5. Anexos

### 3.5.1. Enlaces de Referencia

- **Proyecto en SonarCloud**: https://sonarcloud.io/project/overview?id=CamiLoP19_ProyectoWeb-TallerMecanico
- **Repositorio GitHub**: https://github.com/CamiLoP19/ProyectoWeb-TallerMecanico
- **Dashboard de Métricas**: https://sonarcloud.io/project/activity?id=CamiLoP19_ProyectoWeb-TallerMecanico

### 3.5.2. Comandos Útiles

**Conteo de líneas con PowerShell:**
```powershell
Get-ChildItem -Path "ProyectoWeb" -Include *.cs,*.razor,*.cshtml -Recurse | 
    Get-Content | Measure-Object -Line
```

**Consulta API SonarCloud:**
```powershell
$response = curl.exe -s -u "TOKEN:" "https://sonarcloud.io/api/measures/component?component=CamiLoP19_ProyectoWeb-TallerMecanico&metricKeys=bugs,vulnerabilities,code_smells"
```

### 3.5.3. Glosario de Términos

- **SLOC**: Source Lines of Code - líneas de código ejecutables
- **Code Smell**: Indicador de problemas potenciales en el código
- **Technical Debt**: Esfuerzo estimado para corregir problemas de calidad
- **Quality Gate**: Conjunto de condiciones que debe cumplir el código
- **Cyclomatic Complexity**: Medida de complejidad basada en caminos de ejecución
- **Security Hotspot**: Área sensible de seguridad que requiere revisión manual

---

**Documento generado**: 8 de Noviembre de 2025  
**Autor**: Equipo de Desarrollo - Proyecto Taller Mecánico  
**Versión**: 1.0  
**Estado del Proyecto**: ✅ PASSED - Calidad A en todas las métricas
