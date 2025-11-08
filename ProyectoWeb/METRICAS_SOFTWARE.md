# III. MEDICIÓN DEL SOFTWARE

## 3.1. Introducción

La medición del software es un aspecto fundamental en la ingeniería de software moderna que permite evaluar y cuantificar diversos atributos de los sistemas de software. A través de la aplicación sistemática de métricas, es posible obtener información objetiva sobre la calidad, complejidad, mantenibilidad y otros aspectos críticos del código.

### Importancia de las Métricas de Software

Las métricas de software proporcionan múltiples beneficios:

- **Evaluación Objetiva**: Permiten obtener medidas cuantitativas sobre la calidad del código
- **Detección Temprana de Problemas**: Identifican áreas problemáticas antes de que se conviertan en defectos críticos
- **Mejora Continua**: Facilitan el seguimiento de la evolución del código y la efectividad de las mejoras aplicadas
- **Toma de Decisiones**: Proporcionan información basada en datos para decisiones técnicas y de gestión
- **Control de Calidad**: Establecen estándares medibles para mantener la calidad del software

## 3.1.1. Objetivos

Los objetivos principales de aplicar métricas de software en este proyecto son:

1. **Evaluar el Tamaño del Proyecto**: Cuantificar la magnitud del sistema en términos de líneas de código
2. **Diagnosticar la Calidad Técnica**: Identificar problemas de calidad, seguridad y mantenibilidad
3. **Identificar Áreas Críticas**: Detectar componentes que requieren refactorización o mejoras
4. **Establecer Línea Base**: Crear un punto de referencia para futuras mediciones
5. **Proponer Mejoras**: Generar recomendaciones basadas en los hallazgos del análisis

## 3.1.2. Alcance

Este trabajo de medición aplica los siguientes tipos de métricas:

### Métricas de Tamaño
- **LOC (Lines of Code)**: Líneas de código fuente
- Distribución por tipo de archivo (C#, Razor)
- Distribución por módulos del sistema

### Métricas de Calidad
- **Seguridad**: Vulnerabilidades y puntos críticos de seguridad
- **Fiabilidad**: Bugs y problemas que afectan el funcionamiento
- **Mantenibilidad**: Code smells y deuda técnica

### Métricas de Complejidad
- Duplicación de código
- Cobertura de pruebas

## 3.1.3. Tipos y Herramientas de Métricas

### Herramientas Utilizadas

#### 1. PowerShell (Windows)
Herramienta nativa para análisis básico de líneas de código mediante comandos de consola.

**Ventajas**:
- No requiere instalación adicional
- Análisis rápido y directo
- Resultados inmediatos

#### 2. SonarQube Cloud
Plataforma completa de análisis estático de código que proporciona métricas detalladas de calidad.

**Características**:
- Análisis estático automatizado
- Detección de vulnerabilidades de seguridad
- Identificación de code smells
- Métricas de mantenibilidad
- Seguimiento de deuda técnica
- Integración con GitHub

---

## 3.2. Medición del Software - Atributos Internos

El objetivo de esta sección es generar un diagnóstico completo de la calidad técnica del producto, identificar áreas críticas y proponer acciones concretas para su mejora.

## 3.2.1. Métricas de Tamaño

### a. Tamaño en Líneas de Código - PowerShell

**Herramienta**: PowerShell (Comandos nativos de Windows)

**Comando utilizado**:
```powershell
Get-ChildItem -Recurse -Include *.cs,*.razor | Get-Content | Measure-Object -Line
```

**Resultados Obtenidos**:

```
========================================
  MÉTRICAS DE TAMAÑO - LÍNEAS DE CÓDIGO
========================================

Proyecto: ProyectoWeb - Taller Mecánico
Fecha: 08/11/2025

Archivos C# (.cs)
  - Cantidad: 34 archivos
  - Líneas: 4,087 LOC

Archivos Razor (.razor)
  - Cantidad: 26 archivos
  - Líneas: 5,085 LOC

----------------------------------------
TOTAL GENERAL
----------------------------------------
  Archivos: 60
  Líneas de Código: 9,172 LOC
========================================
```

**Desglose por Carpetas**:

| Carpeta | Archivos | Líneas de Código |
|---------|----------|------------------|
| Pages | 21 | 4,941 |
| Services | 12 | 2,189 |
| Controllers | 8 | 1,236 |
| Models | 10 | 426 |
| Shared | 5 | 144 |
| Data | 2 | 133 |
| **TOTAL** | **60** | **9,172** |

**Análisis**:
- El módulo de **Pages (Páginas)** representa el 53.8% del código total, siendo el componente más grande
- Los **Services** ocupan el segundo lugar con 23.9% del código
- Los **Controllers** contienen 13.5% del código
- Existe un buen balance en la distribución del código según la arquitectura

### b. Tamaño en Líneas de Código - SonarQube Cloud

**Herramienta**: SonarQube Cloud (https://sonarcloud.io)

**Repositorio Analizado**: 
- GitHub: https://github.com/CamiLoP19/ProyectoWeb-TallerMecanico
- Rama: main
- Organización: Cam
- Project Key: CamiLoP19_ProyectoWeb-TallerMecanico

**Resultados de SonarQube Cloud**:

**Líneas de Código Totales: 3,862 líneas**

**Desglose por Módulos**:

| Módulo | Líneas de Código | Seguridad | Fiabilidad | Mantenibilidad | Puntos Críticos | Cobertura | Duplicación |
|--------|------------------|-----------|------------|----------------|-----------------|-----------|-------------|
| **ProyectoWeb** | 3,862 | 73 | 17 | 181 | 5 | 0.0% | 0.0% |
| Controladores | 1,034 | 35 | 2 | 59 | 0 | 0.0% | 0.0% |
| Servicios | 1,915 | 38 | 1 | 118 | 0 | 0.0% | 0.0% |
| Modelos | 347 | 0 | 12 | 0 | 0 | 0.0% | 0.0% |
| Datos | 105 | 0 | 0 | 0 | 1 | 0.0% | 0.0% |
| Páginas | 42 | 0 | 1 | 0 | 3 | 0.0% | 0.0% |

**Nota**: La diferencia en el conteo de líneas entre PowerShell (9,172) y SonarQube (3,862) se debe a que:
- PowerShell cuenta todas las líneas incluyendo espacios y comentarios
- SonarQube cuenta solo líneas de código efectivas (SLOC - Source Lines of Code)
- SonarQube excluye líneas en blanco, comentarios y código generado automáticamente

---

## 3.2.2. Análisis de Resultados

### Hallazgos Principales

#### 1. Tamaño del Proyecto
- **Total LOC (PowerShell)**: 9,172 líneas
- **Total SLOC (SonarQube)**: 3,862 líneas efectivas
- **Archivos totales**: 60 archivos
- **Proyecto de tamaño medio** según estándares de la industria

#### 2. Problemas de Calidad Detectados

**Seguridad (73 issues)**:
- Problemas de seguridad detectados principalmente en Controllers (35) y Services (38)
- 5 puntos críticos de seguridad que requieren atención inmediata

**Fiabilidad (17 issues)**:
- Bugs potenciales distribuidos entre módulos
- Modelos con 12 issues de fiabilidad

**Mantenibilidad (181 issues)**:
- Mayor cantidad de code smells en el proyecto
- Services con 118 issues de mantenibilidad
- Controllers con 59 issues

#### 3. Cobertura de Código
- **0.0% de cobertura** en todo el proyecto
- Indica ausencia total de pruebas unitarias
- **Área crítica que requiere mejora inmediata**

#### 4. Duplicación
- **0.0% de duplicación** - Excelente resultado
- Indica buenas prácticas de reutilización de código

### Áreas Críticas Identificadas

1. **Services**: Mayor cantidad de código y problemas de mantenibilidad
2. **Controllers**: Problemas de seguridad significativos
3. **Ausencia de Pruebas**: Sin cobertura de testing
4. **Puntos Críticos de Seguridad**: 5 vulnerabilidades críticas

---

## 3.2.3. Acciones de Mejora Propuestas

### Prioridad Alta

1. **Implementar Pruebas Unitarias**
   - Objetivo: Alcanzar 60% de cobertura
   - Comenzar con módulos críticos (Services y Controllers)
   - Utilizar xUnit o NUnit para .NET

2. **Resolver Puntos Críticos de Seguridad**
   - Revisar y corregir las 5 vulnerabilidades críticas
   - Aplicar mejores prácticas de seguridad
   - Validar entradas de usuario

3. **Refactorizar Controllers**
   - Reducir los 35 problemas de seguridad
   - Aplicar principios SOLID
   - Mejorar manejo de excepciones

### Prioridad Media

4. **Mejorar Services**
   - Reducir 118 issues de mantenibilidad
   - Aplicar patrones de diseño
   - Dividir servicios grandes en componentes más pequeños

5. **Revisar Modelos**
   - Corregir 12 issues de fiabilidad
   - Validar propiedades correctamente
   - Aplicar Data Annotations

### Prioridad Baja

6. **Documentación del Código**
   - Agregar comentarios XML en métodos públicos
   - Crear README detallado
   - Documentar APIs

---

## 3.3. Conclusiones

El análisis de métricas del proyecto ProyectoWeb - Taller Mecánico revela:

**Aspectos Positivos**:
- Proyecto bien estructurado con separación clara de responsabilidades
- Ausencia de duplicación de código (0.0%)
- Tamaño manejable del proyecto

**Aspectos a Mejorar**:
- Implementación urgente de pruebas unitarias (0% cobertura actual)
- Corrección de vulnerabilidades de seguridad (73 issues)
- Reducción de deuda técnica en mantenibilidad (181 issues)
- Atención inmediata a 5 puntos críticos de seguridad

**Recomendación General**:
El proyecto tiene una base sólida pero requiere trabajo en calidad de código y testing. Se recomienda priorizar la implementación de pruebas y la corrección de problemas de seguridad antes de despliegue en producción.

---

## Anexos

### Pantallazo 1: Métricas PowerShell
![Métricas de líneas de código usando PowerShell]

### Pantallazo 2: Dashboard SonarQube Cloud
![Análisis completo en SonarQube Cloud - Vista de Código]

### Pantallazo 3: Desglose por Módulos
![Distribución de líneas de código por carpetas]

---

**Fecha de análisis**: 08 de Noviembre de 2025  
**Herramientas utilizadas**: PowerShell, SonarQube Cloud  
**Lenguaje**: C# (.NET 8.0), Razor Pages  
**Framework**: ASP.NET Core con Blazor Server
