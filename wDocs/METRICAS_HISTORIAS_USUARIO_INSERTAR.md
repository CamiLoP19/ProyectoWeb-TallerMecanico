## 3.2.5. Métricas de Puntos de Historias de Usuario

### ¿Qué son los Story Points?

Los **Story Points** (Puntos de Historia) son una unidad de medida utilizada en metodologías ágiles (Scrum, XP, Kanban) para estimar el **esfuerzo relativo** necesario para implementar una historia de usuario. A diferencia de estimar en horas, los story points consideran:

- **Complejidad técnica**: Dificultad de implementación
- **Esfuerzo**: Cantidad de trabajo requerido
- **Incertidumbre/Riesgo**: Nivel de conocimiento sobre la tarea

### Escala de Fibonacci Modificada

La estimación se realiza comúnmente usando la secuencia de Fibonacci modificada:

| Puntos | Complejidad | Descripción | Tiempo Aproximado |
|--------|-------------|-------------|-------------------|
| **1** | Trivial | Cambio muy simple, bien conocido | 1-2 horas |
| **2** | Muy Simple | Tarea pequeña, clara y directa | 2-4 horas |
| **3** | Simple | Funcionalidad básica CRUD | 4-8 horas |
| **5** | Media | Funcionalidad con lógica de negocio moderada | 1-2 días |
| **8** | Compleja | Requiere integración o lógica compleja | 2-3 días |
| **13** | Muy Compleja | Múltiples integraciones, alta incertidumbre | 3-5 días |
| **21** | Extremadamente Compleja | Debe dividirse en historias más pequeñas | > 1 semana |

### Metodología de Estimación

#### Planning Poker

Es la técnica más utilizada para estimar story points en equipo:

1. El Product Owner presenta la historia de usuario
2. El equipo discute los detalles y criterios de aceptación
3. Cada miembro elige una carta (1, 2, 3, 5, 8, 13, 21) en secreto
4. Todos revelan sus cartas simultáneamente
5. Se discuten las diferencias y se vuelve a votar hasta alcanzar consenso

---

## Aplicación al Proyecto ProyectoWeb - Taller Mecánico

### Historias de Usuario del Sistema

Basado en los 23 requisitos funcionales, se han identificado las siguientes historias de usuario:

---

### **Épica 1: Gestión de Usuarios y Autenticación**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-01** | Como **cliente nuevo**, quiero **registrarme en el sistema** para poder **solicitar servicios del taller** | - Formulario con validación de datos<br>- Encriptación de contraseña (BCrypt)<br>- Confirmación por email<br>- Registro en Firebase | **5** | Lógica de validación, integración Firebase, envío email |
| **HU-02** | Como **usuario registrado**, quiero **iniciar sesión** para **acceder a mi cuenta** | - Autenticación JWT<br>- Validación de credenciales<br>- Gestión de sesión<br>- Redirección según rol | **3** | CRUD básico con autenticación estándar |
| **HU-03** | Como **usuario autenticado**, quiero **cerrar sesión** para **proteger mi información** | - Invalidar token JWT<br>- Limpiar estado de sesión<br>- Redireccionar al login | **1** | Tarea simple, bien conocida |

**Subtotal Épica 1: 9 Story Points**

---

### **Épica 2: Gestión de Empleados (Admin)**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-04** | Como **administrador**, quiero **registrar nuevos empleados** para que puedan **atender solicitudes** | - Formulario con datos personales<br>- Asignación de rol<br>- Configuración de comisión<br>- Validación de correo único | **5** | CRUD con validaciones y cálculo de comisiones |
| **HU-05** | Como **administrador**, quiero **ver la lista de empleados** para **gestionar el personal** | - Tabla con filtros (activos/todos)<br>- Búsqueda por nombre<br>- Paginación<br>- Acciones (editar, eliminar) | **3** | Listado estándar con filtros básicos |
| **HU-06** | Como **administrador**, quiero **editar datos de empleados** para **mantener información actualizada** | - Formulario pre-cargado<br>- Validaciones<br>- Actualización en Firebase<br>- Confirmación de cambios | **3** | CRUD estándar de actualización |
| **HU-07** | Como **administrador**, quiero **desactivar empleados** para **gestionar personal inactivo** | - Confirmación de eliminación<br>- Soft delete (activo=false)<br>- Verificar solicitudes asignadas | **2** | Tarea simple con validación |

**Subtotal Épica 2: 13 Story Points**

---

### **Épica 3: Gestión de Productos e Inventario**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-08** | Como **administrador**, quiero **registrar productos** para **mantener el inventario actualizado** | - Formulario con imagen<br>- Generación de código de barras<br>- Control de stock<br>- Precio y descripción | **8** | Complejo: generación código barras, manejo imágenes |
| **HU-09** | Como **administrador**, quiero **ver el catálogo de productos** para **consultar inventario** | - Tabla con búsqueda<br>- Filtros (activos/todos)<br>- Visualización de stock<br>- Código de barras visible | **3** | Listado con filtros estándar |
| **HU-10** | Como **administrador**, quiero **actualizar productos** para **corregir información o precios** | - Formulario de edición<br>- Actualizar imagen<br>- Regenerar código de barras (opcional)<br>- Validaciones | **5** | Actualización con manejo de imágenes |
| **HU-11** | Como **administrador**, quiero **desactivar productos** para **no mostrarlos en catálogo** | - Confirmación<br>- Soft delete<br>- Verificar si está en facturas activas | **2** | Tarea simple con validación |

**Subtotal Épica 3: 18 Story Points**

---

### **Épica 4: Gestión de Solicitudes de Servicio**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-12** | Como **cliente**, quiero **crear solicitudes de servicio** para **reparar mi vehículo** | - Formulario detallado (vehículo, problema)<br>- Selección de servicios<br>- Validaciones<br>- Notificación al cliente y admin | **8** | Complejo: múltiples campos, validaciones, notificaciones |
| **HU-13** | Como **cliente**, quiero **ver mis solicitudes** para **hacer seguimiento del estado** | - Lista de solicitudes propias<br>- Filtros por estado<br>- Ver detalles<br>- Código de colores por estado | **3** | Listado con filtros básicos |
| **HU-14** | Como **empleado**, quiero **ver solicitudes asignadas** para **saber qué trabajos atender** | - Dashboard de trabajo<br>- Filtros por estado<br>- Ordenar por prioridad<br>- Ver detalles | **5** | Dashboard con lógica de asignación |
| **HU-15** | Como **empleado**, quiero **actualizar el estado de solicitudes** para **reflejar el progreso** | - Cambiar estado (Pendiente, En Proceso, Completada, Cancelada)<br>- Agregar notas<br>- Validar transiciones de estado<br>- Notificar cliente | **5** | Lógica de máquina de estados + notificaciones |
| **HU-16** | Como **usuario**, quiero **ver detalles de una solicitud** para **conocer toda la información** | - Vista detallada<br>- Historial de cambios<br>- Información del vehículo<br>- Servicios solicitados | **2** | Vista de solo lectura simple |

**Subtotal Épica 4: 23 Story Points**

---

### **Épica 5: Gestión de Facturas y Pagos**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-17** | Como **empleado**, quiero **generar facturas desde solicitudes completadas** para **cobrar servicios** | - Crear factura vinculada a solicitud<br>- Calcular total (servicios + productos)<br>- Generar PDF<br>- Enviar email automático | **13** | Muy complejo: cálculos, generación PDF, integración email |
| **HU-18** | Como **administrador/empleado**, quiero **ver todas las facturas** para **gestionar cobros** | - Lista completa de facturas<br>- Filtros (pagadas, pendientes)<br>- Búsqueda por cliente<br>- Indicadores visuales de estado | **3** | Listado con filtros estándar |
| **HU-19** | Como **cliente**, quiero **ver mis facturas** para **conocer mis deudas** | - Lista de facturas propias<br>- Ver estado de pago<br>- Descargar PDF<br>- Ver abonos realizados | **3** | Listado filtrado por cliente |
| **HU-20** | Como **administrador**, quiero **actualizar estado de pago de facturas** para **registrar pagos** | - Marcar como pagada/pendiente<br>- Validar abonos totales<br>- Actualizar estado automáticamente<br>- Calcular saldo pendiente | **5** | Lógica de negocio con cálculos |
| **HU-21** | Como **administrador**, quiero **reenviar facturas por email** para **recordar pagos pendientes** | - Botón de reenvío<br>- Generar PDF actualizado<br>- Enviar email con adjunto<br>- Confirmar envío | **3** | Funcionalidad con servicio email existente |

**Subtotal Épica 5: 27 Story Points**

---

### **Épica 6: Gestión de Abonos**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-22** | Como **cliente**, quiero **realizar abonos a mis facturas** para **pagar parcial o totalmente** | - Integración con Stripe<br>- Formulario de pago seguro<br>- Registrar abono en sistema<br>- Actualizar saldo factura<br>- Confirmación de pago | **13** | Muy complejo: integración Stripe, transacciones seguras |
| **HU-23** | Como **administrador/cliente**, quiero **ver historial de abonos** para **verificar pagos realizados** | - Lista de abonos<br>- Filtrar por factura o cliente<br>- Ver método de pago<br>- Ver fecha y monto | **2** | Listado simple de consulta |

**Subtotal Épica 6: 15 Story Points**

---

### **Épica 7: Reportes y Analytics**

| ID | Historia de Usuario | Criterios de Aceptación | Story Points | Justificación |
|----|---------------------|-------------------------|--------------|---------------|
| **HU-24** | Como **administrador**, quiero **ver ganancias del taller** para **analizar el negocio** | - Dashboard con gráficos<br>- Filtro por rango de fechas<br>- Cálculo de ganancias por mes<br>- Exportar a PDF<br>- Mostrar facturas pagadas y abonos | **13** | Muy complejo: cálculos complejos, gráficos, generación PDF |

**Subtotal Épica 7: 13 Story Points**

---

## Resumen de Story Points por Épica

| Épica | Cantidad HU | Story Points | % del Total |
|-------|-------------|--------------|-------------|
| **1. Gestión de Usuarios y Autenticación** | 3 | 9 | 7.6% |
| **2. Gestión de Empleados** | 4 | 13 | 11.0% |
| **3. Gestión de Productos e Inventario** | 4 | 18 | 15.3% |
| **4. Gestión de Solicitudes** | 5 | 23 | 19.5% |
| **5. Gestión de Facturas y Pagos** | 5 | 27 | 22.9% |
| **6. Gestión de Abonos** | 2 | 15 | 12.7% |
| **7. Reportes y Analytics** | 1 | 13 | 11.0% |
| **TOTAL** | **24** | **118** | **100%** |

---

## Cálculo de Métricas

### a) Velocidad del Equipo (Velocity)

La **velocidad** es la cantidad promedio de story points que un equipo puede completar en un sprint (iteración).

**Para este proyecto (retrospectiva):**

Asumiendo sprints de **2 semanas** y un equipo de **2 desarrolladores**:

```
Duración del proyecto: ~3 meses = 12 semanas = 6 sprints
Total Story Points: 118
Velocidad promedio = 118 / 6 = 19.67 ≈ 20 story points por sprint
```

**Interpretación:** El equipo completa aproximadamente **20 story points cada 2 semanas**.

---

### b) Conversión a Esfuerzo (Horas-Hombre)

Usando una relación empírica basada en la complejidad:

| Story Points | Horas Promedio |
|--------------|----------------|
| 1 | 2 horas |
| 2 | 4 horas |
| 3 | 6 horas |
| 5 | 12 horas |
| 8 | 20 horas |
| 13 | 32 horas |
| 21 | 48 horas |

**Cálculo del esfuerzo total:**

| Story Points | Cantidad HU | Horas/SP | Total Horas |
|--------------|-------------|----------|-------------|
| 1 | 1 | 2 | 2 |
| 2 | 3 | 4 | 12 |
| 3 | 7 | 6 | 42 |
| 5 | 6 | 12 | 72 |
| 8 | 2 | 20 | 40 |
| 13 | 3 | 32 | 96 |

**Esfuerzo Total:**

```
Esfuerzo = 2 + 12 + 42 + 72 + 40 + 96 = 264 horas-hombre
```

**Nota:** Este esfuerzo considera **solo el desarrollo de funcionalidades** (coding). No incluye:
- Análisis y diseño
- Pruebas (testing)
- Documentación
- Reuniones y ceremonias ágiles
- Corrección de bugs

Para obtener el esfuerzo real total, se aplica un **factor de multiplicación de 3-4x**:

```
Esfuerzo real estimado = 264 × 3.5 = 924 horas-hombre
```

---

### c) Conversión a LOC

Usando una relación empírica de **35 LOC por Story Point** para proyectos C#/Blazor:

```
LOC estimado = 118 × 35 = 4,130 LOC
KLOC = 4.13 KLOC
```

---

## Validación con Mediciones Reales

| Métrica | Estimado (Story Points) | Medido (Real) | Diferencia | % Variación |
|---------|-------------------------|---------------|------------|-------------|
| Story Points | 118 | N/A | N/A | N/A |
| LOC (35 LOC/SP) | 4,130 | 9,870 | -5,740 | -58.2% ❌ |
| Esfuerzo desarrollo | 264 horas | N/A | N/A | N/A |
| Esfuerzo total (×3.5) | 924 horas | N/A | N/A | N/A |

**Análisis de Variación:**

La métrica de Story Points **subestima significativamente** el tamaño del código (-58.2%). Razones:

1. **Factor conservador**: 35 LOC/SP es bajo para aplicaciones full-stack
2. **Código adicional no capturado**: Validaciones, DTOs, models, configuración
3. **Servicios de infraestructura**: Firebase, Stripe, Email no están en historias de usuario
4. **Componentes Blazor**: HTML + C# en archivos .razor aumentan LOC
5. **Story Points miden esfuerzo funcional**, no líneas de código totales

**Ajuste del Factor LOC/SP:**

Calculando el factor real:

```
Factor real = 9,870 LOC / 118 SP = 83.6 LOC/SP
```

Este factor de **83.6 LOC/SP** es más realista para:
- Aplicaciones Blazor Server full-stack
- 46 clases (models, DTOs, controllers, services)
- 103 métodos con lógica compleja
- Integración con múltiples APIs externas

**LOC ajustado:**

```
LOC = 118 × 83.6 = 9,865 LOC ≈ 9.87 KLOC ✅
```

---

## Ventajas y Limitaciones

### ✅ Ventajas de Story Points

1. **Estimación relativa**: Más fácil comparar complejidades que estimar horas exactas
2. **Independiente de personas**: No depende de la velocidad individual
3. **Considera incertidumbre**: Incluye complejidad, esfuerzo y riesgo
4. **Mejora con el tiempo**: La velocidad del equipo se estabiliza tras varios sprints
5. **Facilita planning**: Permite priorizar y planificar releases

### ⚠️ Limitaciones

1. **No mide tamaño de código**: Story Points ≠ LOC
2. **Requiere calibración**: Cada equipo tiene su propia escala
3. **Subjetivo**: Depende de la experiencia del equipo
4. **No comparable entre equipos**: 5 SP de un equipo ≠ 5 SP de otro
5. **Curva de aprendizaje**: El equipo debe entrenar la estimación

---

## Comparación con Otras Métricas

| Métrica | LOC Estimado | Esfuerzo Estimado | Precisión | Observaciones |
|---------|--------------|-------------------|-----------|---------------|
| **Puntos de Función** | 10,960 | 3,600 horas | +11% | Sobrestima ligeramente |
| **Puntos de Casos de Uso** | 7,950 | 3,180 horas | -19.4% | Subestima conservadoramente |
| **Object Points** | 9,868 | 3,766 horas | -0.02% | **Muy preciso** |
| **Story Points** | 4,130 (35 LOC/SP) | 924 horas (×3.5) | -58.2% | Subestima significativamente |
| **Story Points Ajustado** | 9,865 (83.6 LOC/SP) | N/A | -0.05% | **Preciso con factor real** |

---

## Resumen Final

| Métrica | Valor |
|---------|-------|
| **Total Historias de Usuario** | 24 HU |
| **Total Story Points** | 118 SP |
| **Velocidad Promedio** | 20 SP/sprint (2 semanas) |
| **Sprints Totales** | 6 sprints |
| **Duración Proyecto** | 12 semanas (3 meses) |
| **Esfuerzo Desarrollo** | 264 horas-hombre |
| **Esfuerzo Total (×3.5)** | 924 horas-hombre |
| **LOC Estimado (35 LOC/SP)** | 4,130 LOC |
| **LOC Medido Real** | 9,870 LOC |
| **Factor Real LOC/SP** | 83.6 LOC/SP |
| **LOC Ajustado** | 9,865 LOC ≈ **9.87 KLOC ✅** |
| **Precisión Ajustada** | 99.95% |

---

## Conclusión

Los **Story Points** son una métrica ágil efectiva para:
- **Planificación de sprints** y releases
- **Estimación relativa** de complejidad
- **Seguimiento de velocidad** del equipo
- **Priorización** de backlog

Sin embargo, **NO son ideales para estimar tamaño de código (LOC)** ya que se enfocan en esfuerzo funcional desde la perspectiva del usuario, no en implementación técnica completa.

Para este proyecto, el factor ajustado de **83.6 LOC/SP** refleja la realidad de una aplicación Blazor Server completa con 46 clases, 103 métodos, y múltiples integraciones externas (Firebase, Stripe, Email).

**Recomendación:** Usar Story Points para gestión ágil y planificación, pero complementar con métricas como Object Points o Puntos de Función para estimaciones de tamaño y esfuerzo total del proyecto.
