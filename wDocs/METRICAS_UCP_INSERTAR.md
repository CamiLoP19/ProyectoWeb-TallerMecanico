## 3.2.3. Métricas de Puntos de Casos de Uso

### a) Calcular los Puntos de Casos de Uso Sin Ajustar (UUCW)

Los casos de uso se clasifican según su complejidad basándose en el número de transacciones:
- **Simple**: 1-3 transacciones = 5 puntos
- **Medio**: 4-7 transacciones = 10 puntos
- **Complejo**: 8+ transacciones = 15 puntos

#### Clasificación de Casos de Uso:

| # | Caso de Uso | Transacciones | Complejidad | Peso |
|---|-------------|---------------|-------------|------|
| 1 | RF-01: Registro de Clientes | 2 (Validar, Crear) | Simple | 5 |
| 2 | RF-02: Inicio de Sesión | 2 (Validar, Crear sesión) | Simple | 5 |
| 3 | RF-03: Crear Empleado | 3 (Validar, Crear usuario, Crear empleado) | Simple | 5 |
| 4 | RF-04: Listar Empleados | 1 (Consultar) | Simple | 5 |
| 5 | RF-05: Actualizar Empleado | 2 (Validar, Actualizar) | Simple | 5 |
| 6 | RF-06: Eliminar Empleado | 1 (Soft delete) | Simple | 5 |
| 7 | RF-07: Crear Producto | 2 (Validar, Crear) | Simple | 5 |
| 8 | RF-08: Listar Productos | 1 (Consultar) | Simple | 5 |
| 9 | RF-09: Actualizar Producto | 2 (Validar, Actualizar) | Simple | 5 |
| 10 | RF-10: Eliminar Producto | 1 (Soft delete) | Simple | 5 |
| 11 | RF-11: Crear Servicio | 2 (Validar, Crear) | Simple | 5 |
| 12 | RF-12: Listar Servicios | 1 (Consultar) | Simple | 5 |
| 13 | RF-13: Actualizar Servicio | 2 (Validar, Actualizar) | Simple | 5 |
| 14 | RF-14: Crear Solicitud | 3 (Validar, Crear, Notificar) | Simple | 5 |
| 15 | RF-15: Listar Solicitudes por Cliente | 2 (Validar, Consultar) | Simple | 5 |
| 16 | RF-16: Listar Solicitudes por Empleado | 2 (Validar, Consultar) | Simple | 5 |
| 17 | RF-17: Actualizar Estado Solicitud | 3 (Validar, Actualizar, Notificar) | Simple | 5 |
| 18 | RF-18: Consultar Solicitud | 1 (Consultar detalles) | Simple | 5 |
| 19 | RF-19: Crear Factura | 5 (Validar, Calcular, Generar, Crear, Código barras) | Medio | 10 |
| 20 | RF-20: Generar Factura desde Solicitud | 7 (Validar solicitud, Obtener servicio, Validar productos, Calcular, Crear, Actualizar, Email) | Medio | 10 |
| 21 | RF-21: Listar Facturas | 1 (Consultar) | Simple | 5 |
| 22 | RF-22: Listar Facturas por Cliente | 2 (Validar, Consultar) | Simple | 5 |
| 23 | RF-23: Actualizar Estado Pago | 2 (Validar, Actualizar) | Simple | 5 |
| 24 | RF-24: Reenviar Factura Email | 4 (Obtener, Generar PDF, Enviar, Registrar) | Medio | 10 |
| 25 | RF-25: Crear Abono | 4 (Validar factura, Validar monto, Crear, Actualizar saldo) | Medio | 10 |
| 26 | RF-26: Listar Abonos | 2 (Validar, Consultar) | Simple | 5 |
| 27 | RF-27: Ver Ganancias y Exportar PDF | 6 (Consultar, Calcular ganancias, Calcular comisiones, Agrupar, Generar PDF, Retornar) | Medio | 10 |

**Resumen UUCW:**

| Complejidad | Cantidad | Peso | Total |
|-------------|----------|------|-------|
| Simple | 22 | 5 | 110 |
| Medio | 5 | 10 | 50 |
| Complejo | 0 | 15 | 0 |
| **TOTAL UUCW** | **27** | | **160** |

---

### b) Calcular los Puntos de Actor Sin Ajustar (UAW)

Los actores se clasifican según su complejidad de interfaz:
- **Simple**: Sistema con API definida = 1 punto
- **Medio**: Protocolo (HTTP, FTP, etc.) = 2 puntos
- **Complejo**: Interfaz gráfica (humano) = 3 puntos

#### Clasificación de Actores:

| Actor | Tipo | Complejidad | Peso |
|-------|------|-------------|------|
| Cliente | Humano - Interfaz web Blazor | Complejo | 3 |
| Empleado | Humano - Interfaz web Blazor | Complejo | 3 |
| Administrador | Humano - Interfaz web Blazor | Complejo | 3 |
| Sistema Email (SMTP) | Protocolo - Email automático | Medio | 2 |
| Firebase/Firestore | API - Base de datos | Simple | 1 |
| Stripe API | API - Pasarela de pagos | Simple | 1 |

**Resumen UAW:**

| Complejidad | Cantidad | Peso | Total |
|-------------|----------|------|-------|
| Simple | 2 | 1 | 2 |
| Medio | 1 | 2 | 2 |
| Complejo | 3 | 3 | 9 |
| **TOTAL UAW** | **6** | | **13** |

---

### c) Factor Técnico (TF)

El Factor Técnico evalúa 13 factores técnicos del sistema. Cada factor se puntúa de 0 a 5.

#### Evaluación de Factores Técnicos:

| # | Factor Técnico | Peso | Valor | Cálculo |
|---|----------------|------|-------|---------|
| T1 | Sistema distribuido | 2 | 5 | 10 |
| T2 | Tiempo de respuesta o rendimiento | 1 | 4 | 4 |
| T3 | Eficiencia del usuario final | 1 | 5 | 5 |
| T4 | Procesamiento interno complejo | 1 | 4 | 4 |
| T5 | Código reutilizable | 1 | 4 | 4 |
| T6 | Facilidad de instalación | 0.5 | 5 | 2.5 |
| T7 | Facilidad de uso | 0.5 | 5 | 2.5 |
| T8 | Portabilidad | 2 | 3 | 6 |
| T9 | Facilidad de cambio | 1 | 4 | 4 |
| T10 | Concurrencia | 1 | 5 | 5 |
| T11 | Características de seguridad | 1 | 5 | 5 |
| T12 | Acceso directo a terceras partes | 1 | 5 | 5 |
| T13 | Facilidades de entrenamiento requeridas | 1 | 2 | 2 |

**Justificación de valores asignados:**

- **T1 (Sistema distribuido) = 5 ESENCIAL**: Firebase cloud, Stripe API, SMTP - arquitectura completamente distribuida
- **T2 (Rendimiento) = 4 MEDIO**: Consultas en tiempo real a Firebase, múltiples usuarios concurrentes
- **T3 (Eficiencia usuario) = 5 ESENCIAL**: Blazor Server con interfaz reactiva, validaciones inmediatas
- **T4 (Procesamiento complejo) = 4 MEDIO**: Cálculo de ganancias, generación facturas, inventarios
- **T5 (Reutilizable) = 4 MEDIO**: Servicios inyectables, componentes Blazor compartidos
- **T6 (Instalación) = 5 ESENCIAL**: Deployment cloud, configuración automática, setup.ps1
- **T7 (Facilidad de uso) = 5 ESENCIAL**: Interfaz intuitiva, dashboards por rol, navegación clara
- **T8 (Portabilidad) = 3 MEDIO**: .NET 8 multiplataforma pero con dependencias Windows
- **T9 (Facilidad de cambio) = 4 MEDIO**: Arquitectura en capas, inyección de dependencias
- **T10 (Concurrencia) = 5 ESENCIAL**: Múltiples usuarios simultáneos, transacciones concurrentes
- **T11 (Seguridad) = 5 ESENCIAL**: Autenticación JWT, roles, BCrypt, validación servidor
- **T12 (Acceso terceros) = 5 ESENCIAL**: Firebase, Stripe, SMTP - APIs externas críticas
- **T13 (Entrenamiento) = 2 IRRELEVANTE**: Sistema autoexplicativo, no requiere capacitación

**Cálculo TF:**

```
TFactor = Σ(Peso × Valor) = 10+4+5+4+4+2.5+2.5+6+4+5+5+5+2 = 59

TF = 0.6 + (0.01 × TFactor)
TF = 0.6 + (0.01 × 59)
TF = 0.6 + 0.59
TF = 1.19
```

---

### d) Factor Ambiental (EF)

El Factor Ambiental evalúa 8 factores relacionados con el equipo de desarrollo.

#### Evaluación de Factores Ambientales:

| # | Factor Ambiental | Peso | Valor | Cálculo |
|---|------------------|------|-------|---------|
| E1 | Familiaridad con el modelo de proyecto (UML) | 1.5 | 3 | 4.5 |
| E2 | Personal tiempo parcial | -1 | 2 | -2 |
| E3 | Capacidad del analista líder | 0.5 | 4 | 2 |
| E4 | Experiencia en la aplicación | 0.5 | 3 | 1.5 |
| E5 | Experiencia en orientación a objetos | 1 | 4 | 4 |
| E6 | Motivación | 1 | 5 | 5 |
| E7 | Dificultad del lenguaje de programación | -1 | 2 | -2 |
| E8 | Estabilidad de los requerimientos | 2 | 4 | 8 |

**Justificación de valores asignados:**

- **E1 (Familiaridad UML) = 3 MEDIO**: Conocimiento básico de modelado, diagramas de casos de uso estándar
- **E2 (Personal part-time) = 2 IRRELEVANTE**: Equipo con disponibilidad parcial para el proyecto académico
- **E3 (Capacidad líder) = 4 MEDIO**: Analista con buena capacidad técnica y de coordinación
- **E4 (Experiencia aplicación) = 3 MEDIO**: Experiencia previa con sistemas de gestión similares
- **E5 (Orientación objetos) = 4 MEDIO**: Buen dominio de POO con C# y .NET
- **E6 (Motivación) = 5 ESENCIAL**: Equipo altamente motivado para completar el proyecto exitosamente
- **E7 (Dificultad lenguaje) = 2 IRRELEVANTE**: C# es un lenguaje moderno y bien documentado
- **E8 (Estabilidad requisitos) = 4 MEDIO**: Requisitos bien definidos con pocos cambios durante desarrollo

**Cálculo EF:**

```
EFactor = Σ(Peso × Valor) = 4.5-2+2+1.5+4+5-2+8 = 21

EF = 1.4 + (-0.03 × EFactor)
EF = 1.4 + (-0.03 × 21)
EF = 1.4 - 0.63
EF = 0.77
```

---

### e) Calcular los UCP (Use Case Points)

**Fórmula:**

```
UUCP = UUCW + UAW
UUCP = 160 + 13
UUCP = 173

UCP = UUCP × TF × EF
UCP = 173 × 1.19 × 0.77
UCP = 173 × 0.9163
UCP = 158.52 ≈ 159 UCP
```

---

### Conversión a Horas-Hombre y LOC

**Estimación de Esfuerzo:**

Usando el factor estándar de **20 horas/UCP**:

```
Esfuerzo = 159 UCP × 20 horas/UCP = 3,180 horas-hombre
```

**Conversión a LOC:**

Usando el factor de **50 LOC/UCP** para aplicaciones web con frameworks modernos:

```
LOC estimado = 159 × 50 = 7,950 LOC
KLOC = 7.95 KLOC
```

---

### Validación con Mediciones Reales

| Métrica | Estimado (UCP) | Medido (PowerShell) | Diferencia |
|---------|----------------|---------------------|------------|
| LOC | 7,950 | 9,870 | -19.4% ✅ |
| KLOC | 7.95 | 9.87 | -19.4% ✅ |

**Conclusión:** La diferencia del -19.4% es **EXCELENTE** (dentro del rango ±20%). La estimación por UCP es conservadora, lo que indica que:
- El equipo implementó código adicional robusto y completo
- Las validaciones y manejo de errores añaden líneas significativas
- La alta motivación (E6=5) resultó en características adicionales de calidad
- **La métrica UCP es VÁLIDA y COHERENTE con la medición real**

---

### Resumen Final

| Métrica | Valor |
|---------|-------|
| **UUCW** | 160 puntos |
| **UAW** | 13 puntos |
| **UUCP** | 173 puntos |
| **TF** | 1.19 |
| **EF** | 0.77 |
| **UCP** | 159 puntos |
| **Esfuerzo Estimado** | 3,180 horas-hombre |
| **LOC Estimado** | 7,950 LOC (7.95 KLOC) |
| **LOC Medido** | 9,870 LOC (9.87 KLOC) |
| **Precisión** | 80.6% ✅ |
