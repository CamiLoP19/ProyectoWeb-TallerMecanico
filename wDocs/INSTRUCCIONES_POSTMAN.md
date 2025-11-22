# 📋 Colección Postman - Taller Mecánico (13 Casos de Uso)

## ✅ Correcciones Aplicadas

Esta colección incluye **TODAS las correcciones** descubiertas durante las pruebas:

### 1. **Campo RolUsuario Requerido**
- ✅ Agregado en CA001 (Registrarse)
- ✅ Agregado en CA011-A (Crear Empleado)

### 2. **Generar Factura - Estructura Corregida**
- ✅ Usa `Detalles` en vez de `ProductosUtilizados`
- ✅ Incluye `ProductoNombre`, `PrecioUnitario`, `Subtotal` en cada detalle
- ✅ Campo `PorcentajeComision` configurado a 0.6 (60% empleado)

### 3. **Actualizar Empleado - Objeto Completo**
- ✅ Script prerequest que obtiene el empleado actual
- ✅ Envía el objeto completo con `Id` incluido
- ✅ Modifica solo los campos necesarios

### 4. **Actualizar Stock - Número Directo**
- ✅ Envía el número entero `60` directamente
- ✅ No usa objeto con `CantidadCambio`

## 📥 Importar en Postman

1. Abre Postman
2. Click en **Import**
3. Arrastra el archivo `Taller_13_Casos_CORREGIDO.postman_collection.json`
4. La colección se importará con todas las variables

## ▶️ Cómo Ejecutar

### Opción 1: Runner (Recomendado para pruebas completas)

1. Click derecho en la colección → **Run collection**
2. Asegúrate que el servidor esté corriendo en `http://localhost:5000`
3. Click en **Run Taller Mecánico**
4. Verás los resultados de los 18 requests en orden

### Opción 2: Manual (Para pruebas individuales)

Ejecutar en este orden para que las variables se capturen:

1. **CA001** - Registrarse (captura `clienteId`)
2. **CA002** - Login Admin
3. **CA011-A** - Crear Empleado (captura `empleadoId`)
4. **CA012-A** - Crear Producto (captura `productoId`, `productoPrecio`, `productoNombre`)
5. **CA003** - Solicitar Servicio (captura `solicitudId`)
6. **CA004** - Ver Solicitudes Cliente
7. **CA005** - Ver Detalle Solicitud
8. **CA008** - Listar Pendientes
9. **CA009** - Atender Solicitud
10. **CA010** - Generar Factura (captura `facturaId`)
11. **CA006** - Ver Facturas Cliente
12. **CA007** - Registrar Abono
13. **CA011-B** - Listar Empleados
14. **CA011-C** - Actualizar Empleado
15. **CA012-B** - Listar Productos
16. **CA012-C** - Actualizar Stock
17. **CA013** - Ver Todas Facturas
18. **CA011-D** - Eliminar Empleado

## 🔧 Variables de Colección

La colección usa estas variables que se capturan automáticamente:

| Variable | Se captura en | Se usa en |
|----------|---------------|-----------|
| `baseUrl` | Manual (http://localhost:5000) | Todos |
| `clienteId` | CA001 | CA003, CA004, CA006, CA007 |
| `empleadoId` | CA011-A | CA009, CA011-C, CA011-D |
| `productoId` | CA012-A | CA010, CA012-C |
| `productoNombre` | CA012-A | CA010 |
| `productoPrecio` | CA012-A | CA010 |
| `solicitudId` | CA003 | CA005, CA009, CA010 |
| `facturaId` | CA010 | CA007 |

## 📝 Scripts de Test Incluidos

Cada request tiene validaciones automáticas:

- ✅ Verifica códigos de respuesta correctos
- ✅ Valida que los IDs se generen
- ✅ Comprueba valores específicos (Rol, Estados, Totales)
- ✅ Verifica arrays no vacíos

## 🎯 Casos de Uso Cubiertos

| Código | Descripción | Método | Endpoint |
|--------|-------------|--------|----------|
| CA001 | Registrarse (Cliente) | POST | `/api/auth/registro` |
| CA002 | Login Admin | POST | `/api/auth/login` |
| CA003 | Solicitar Servicio | POST | `/api/solicitud` |
| CA004 | Ver Solicitudes Cliente | GET | `/api/solicitud/cliente/{id}` |
| CA005 | Ver Detalle Solicitud | GET | `/api/solicitud/{id}` |
| CA006 | Ver Facturas Cliente | GET | `/api/factura/cliente/{id}` |
| CA007 | Registrar Abono | POST | `/api/abono` |
| CA008 | Listar Pendientes | GET | `/api/solicitud/pendientes` |
| CA009 | Atender Solicitud | PUT | `/api/solicitud/{id}/asignar` |
| CA010 | Generar Factura | POST | `/api/factura/generar` |
| CA011-A | Crear Empleado | POST | `/api/empleado` |
| CA011-B | Listar Empleados | GET | `/api/empleado` |
| CA011-C | Actualizar Empleado | PUT | `/api/empleado/{id}` |
| CA011-D | Eliminar Empleado | DELETE | `/api/empleado/{id}` |
| CA012-A | Crear Producto | POST | `/api/producto` |
| CA012-B | Listar Productos | GET | `/api/producto` |
| CA012-C | Actualizar Stock | PUT | `/api/producto/{id}/stock` |
| CA013 | Ver Todas Facturas | GET | `/api/factura` |

## ⚠️ Puntos Importantes

### 1. Orden de Ejecución
Los requests **DEBEN** ejecutarse en orden porque hay dependencias:
- Solicitud requiere ClienteId
- Generar Factura requiere SolicitudId, EmpleadoId, ProductoId
- Registrar Abono requiere FacturaId

### 2. Valores Dinámicos
La colección usa `{{$timestamp}}` para generar usuarios únicos en cada ejecución.

### 3. Prerequisitos
- ✅ Servidor ASP.NET corriendo en `http://localhost:5000`
- ✅ Usuario admin creado (admin/2345)
- ✅ Firebase configurado

## 🐛 Troubleshooting

### Error 400 en Registrarse o Crear Empleado
- ✅ Verifica que `RolUsuario` esté incluido en el JSON

### Error 400 en Generar Factura
- ✅ Asegúrate que usa `Detalles` (no `ProductosUtilizados`)
- ✅ Verifica que cada detalle tenga `ProductoNombre`, `PrecioUnitario`, `Subtotal`

### Error 400 en Actualizar Empleado
- ✅ El script prerequest debe ejecutarse primero (obtiene empleado completo)
- ✅ El body debe incluir el `Id` del empleado

### Error 400 en Actualizar Stock
- ✅ Envía solo el número `60`, no `{"CantidadCambio": 60}`

## 📊 Resultados Esperados

Al ejecutar la colección completa:
- ✅ 18/18 requests exitosos (100%)
- ✅ Todos los tests en verde
- ✅ Variables capturadas correctamente
- ✅ Factura con Total > 0

## 📸 Captura de Pantalla para Documentación

Para tu documentación de pruebas:

1. Ejecuta el Runner
2. Espera que termine
3. Captura pantalla mostrando:
   - ✅ 18/18 tests passed
   - ✅ Tiempos de respuesta
   - ✅ Panel de variables con IDs generados

---

**Autor:** Generado automáticamente desde scripts PowerShell validados  
**Fecha:** 14 de Noviembre 2025  
**Versión:** 2.0 - CORREGIDA
