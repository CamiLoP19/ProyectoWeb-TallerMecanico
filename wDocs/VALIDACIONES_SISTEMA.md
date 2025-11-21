# ✅ VALIDACIONES DEL SISTEMA

## 📋 ÍNDICE
1. [Validaciones de Usuario/Cliente](#validaciones-de-usuariocliente)
2. [Validaciones de Empleado](#validaciones-de-empleado)
3. [Validaciones de Producto](#validaciones-de-producto)
4. [Validaciones de Servicio](#validaciones-de-servicio)
5. [Validaciones de Solicitud](#validaciones-de-solicitud)
6. [Validaciones de Abono/Pago](#validaciones-de-abonopago)
7. [Validaciones de Login](#validaciones-de-login)

---

## 1. VALIDACIONES DE USUARIO/CLIENTE

### CU-01: Registrarse

**Implementación:** `UsuarioDto` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **NombreUsuario** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 50 caracteres<br>• Solo letras, números y guion bajo | `juan_123`<br>`maria_garcia`<br>`admin` | `ju` ❌ (muy corto)<br>`juan 123` ❌ (tiene espacio)<br>`josé@admin` ❌ (tiene símbolos) |
| **Password** | • Obligatorio<br>• Mínimo 6 caracteres<br>• Máximo 100 caracteres | `miPass123`<br>`seguridadTotal!` | `12345` ❌ (muy corta)<br>`123` ❌ (muy corta) |
| **CorreoElectronico** | • Obligatorio<br>• Formato válido de email<br>• Máximo 100 caracteres | `juan@gmail.com`<br>`maria.garcia@empresa.com` | `juangmail.com` ❌ (sin @)<br>`maria@` ❌ (incompleto)<br>`@gmail.com` ❌ (sin usuario) |
| **NombreCompleto** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 100 caracteres<br>• Solo letras (incluye acentos) y espacios | `Juan Pérez`<br>`María José García`<br>`José Luis` | `J` ❌ (muy corto)<br>`Juan123` ❌ (tiene números)<br>`Juan_Pérez` ❌ (tiene guion bajo) |

**Validaciones Adicionales en Backend:**
- ✅ Nombre de usuario único en TODO el sistema (usuarios + empleados)
- ✅ Correo electrónico único en TODO el sistema (usuarios + empleados)

**Mensajes de Error:**
```json
{
  "message": "Errores de validación",
  "errors": [
    {
      "Campo": "NombreUsuario",
      "Errores": ["El nombre de usuario solo puede contener letras, números y guiones bajos"]
    },
    {
      "Campo": "CorreoElectronico",
      "Errores": ["El correo debe tener un formato válido"]
    }
  ]
}
```

---

## 2. VALIDACIONES DE EMPLEADO

### CU-11: Gestionar Empleados (Crear/Actualizar)

**Implementación:** `EmpleadoValidado` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **NombreUsuario** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 50 caracteres<br>• Solo letras, números y guion bajo | `empleado_01`<br>`mecanico_principal` | `em` ❌ (muy corto)<br>`mec ánico` ❌ (tiene espacio) |
| **Password** | • Obligatorio<br>• Mínimo 6 caracteres<br>• Máximo 100 caracteres | `passEmpleado123` | `12345` ❌ (muy corta) |
| **CorreoElectronico** | • Obligatorio<br>• Formato válido de email<br>• Máximo 100 caracteres | `empleado@taller.com` | `empleadotaller.com` ❌ (sin @) |
| **NombreCompleto** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 100 caracteres<br>• Solo letras y espacios | `Pedro Martínez`<br>`Ana María López` | `P` ❌ (muy corto)<br>`Pedro123` ❌ (tiene números) |
| **PorcentajeComision** | • Obligatorio<br>• Valor entre 0 y 1<br>• Default: 0.80 (80%) | `0.80` (80%)<br>`0.75` (75%)<br>`0.90` (90%) | `80` ❌ (debe ser decimal)<br>`1.5` ❌ (supera 100%)<br>`-0.5` ❌ (negativo) |

**Validaciones Adicionales en Backend:**
- ✅ Nombre de usuario único en TODO el sistema
- ✅ Correo electrónico único en TODO el sistema
- ✅ Al actualizar, no puede duplicar usuario/correo de otros empleados

**Ejemplo de Comisión:**
- Si `PorcentajeComision = 0.80`:
  - Empleado recibe: 80% del precio del servicio
  - Dueño recibe: 20% del precio del servicio

---

## 3. VALIDACIONES DE PRODUCTO

### CU-12: Gestionar Productos (Crear/Actualizar)

**Implementación:** `ProductoValidado` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **Nombre** | • Obligatorio<br>• Mínimo 2 caracteres<br>• Máximo 100 caracteres<br>• Letras, números, espacios, guiones y puntos | `Aceite 10W-40`<br>`Filtro de aire`<br>`Llanta R15` | `A` ❌ (muy corto)<br>`Aceite@10W` ❌ (tiene @) |
| **Descripcion** | • Opcional<br>• Máximo 500 caracteres | `Aceite sintético de alta calidad` | (texto > 500 caracteres) ❌ |
| **Precio** | • Obligatorio<br>• Mayor a 0.01<br>• Menor a 1,000,000 | `25.50`<br>`1500.00`<br>`99.99` | `0` ❌ (debe ser mayor a 0)<br>`0.001` ❌ (muy bajo)<br>`1500000` ❌ (supera límite) |
| **Stock** | • Obligatorio<br>• Entre 0 y 100,000 | `0` (sin stock)<br>`50`<br>`1000` | `-5` ❌ (negativo)<br>`150000` ❌ (supera límite) |

**Tipo de Dato:**
- `Precio`: **double** (acepta decimales)
- `Stock`: **int** (número entero)
- `Nombre`: **string** (texto)

**Validaciones Adicionales en Backend:**
- ✅ No permite crear productos con precio 0 o negativo
- ✅ No permite stock negativo
- ✅ Al generar factura, valida que haya stock suficiente

---

## 4. VALIDACIONES DE SERVICIO

### CU-13: Gestionar Servicios (Crear/Actualizar)

**Implementación:** `ServicioValidado` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **Nombre** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 100 caracteres<br>• Letras, números, espacios y guiones | `Cambio de aceite`<br>• `Revisión general`<br>• `Balanceo-alineación` | `Ca` ❌ (muy corto)<br>`Cambio@aceite` ❌ (tiene @) |
| **Descripcion** | • Opcional<br>• Máximo 500 caracteres | `Cambio de aceite y filtro con revisión de niveles` | (texto > 500 caracteres) ❌ |
| **PrecioBase** | • Obligatorio<br>• Mayor a 0.01<br>• Menor a 1,000,000 | `150.00`<br>`500.50`<br>`2500.00` | `0` ❌ (debe ser mayor a 0)<br>`-150` ❌ (negativo) |

**Tipo de Dato:**
- `PrecioBase`: **double** (acepta decimales)
- `Nombre`: **string** (solo texto y números permitidos)

**Nota:** El precio base del servicio es lo que cobra el taller. De este monto se calcula la comisión del empleado.

---

## 5. VALIDACIONES DE SOLICITUD

### CU-03: Solicitar Servicio

**Implementación:** `SolicitudServicioValidado` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **ClienteId** | • Obligatorio<br>• Debe existir en la BD | `abc123xyz` (ID válido) | ` ` ❌ (vacío)<br>`null` ❌ |
| **Descripcion** | • Obligatorio<br>• Mínimo 10 caracteres<br>• Máximo 500 caracteres | `Mi auto hace ruido al frenar y vibra` | `Ruido` ❌ (muy corto)<br>(texto > 500 caracteres) ❌ |
| **Detalle** | • Opcional<br>• Máximo 1000 caracteres | `El ruido se escucha más fuerte cuando freno en bajada` | (texto > 1000 caracteres) ❌ |

**Tipo de Dato:**
- Todos los campos son **string** (texto)

**Validaciones Adicionales en Backend:**
- ✅ ClienteId debe ser de un usuario con rol Cliente (3)
- ✅ ClienteId debe ser un usuario activo
- ✅ Se asigna automáticamente: Estado = Pendiente (1), FechaSolicitud = DateTime.UtcNow

---

## 6. VALIDACIONES DE ABONO/PAGO

### CU-07: Pagar Factura (Abono Manual)

**Implementación:** `AbonoValidado` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **FacturaId** | • Obligatorio<br>• Debe existir en la BD | `factura123xyz` | ` ` ❌ (vacío) |
| **Monto** | • Obligatorio<br>• Mayor a 0.01<br>• Menor a 1,000,000<br>• No puede exceder el saldo | `100.00`<br>`500.50` | `0` ❌ (debe ser mayor a 0)<br>`-100` ❌ (negativo) |
| **MetodoPago** | • Obligatorio<br>• Solo valores: Efectivo, Tarjeta, Transferencia, Stripe | `Efectivo`<br>`Tarjeta`<br>`Transferencia`<br>`Stripe` | `PayPal` ❌ (no permitido)<br>`Cheque` ❌ (no permitido) |
| **Observaciones** | • Opcional<br>• Máximo 500 caracteres | `Pago parcial del servicio` | (texto > 500 caracteres) ❌ |

**Tipo de Dato:**
- `Monto`: **double** (acepta decimales)
- `MetodoPago`: **string** (solo valores específicos)
- `Observaciones`: **string** (texto libre)

**Validaciones Adicionales en Backend:**
- ✅ FacturaId debe existir
- ✅ Factura no debe estar ya pagada
- ✅ Monto no puede exceder el saldo pendiente
- ✅ Si monto = saldo, marca factura como Pagada automáticamente

**Ejemplo:**
```json
// Correcto
{
  "FacturaId": "abc123",
  "Monto": 500.00,
  "MetodoPago": "Efectivo",
  "Observaciones": "Pago parcial"
}

// Incorrecto
{
  "FacturaId": "abc123",
  "Monto": 0,  // ❌ Debe ser mayor a 0
  "MetodoPago": "Bitcoin",  // ❌ No es un método válido
  "Observaciones": null
}
```

---

## 7. VALIDACIONES DE LOGIN

### CU-02: Iniciar Sesión

**Implementación:** `LoginRequestValidated` en `DTOsValidados.cs`

| Campo | Validaciones | Ejemplo Válido | Ejemplo Inválido |
|-------|-------------|----------------|------------------|
| **NombreUsuario** | • Obligatorio<br>• Mínimo 3 caracteres<br>• Máximo 50 caracteres<br>• Solo letras, números y guion bajo | `admin`<br>`juan_123` | `ju` ❌ (muy corto)<br>`juan 123` ❌ (tiene espacio) |
| **Password** | • Obligatorio<br>• Mínimo 6 caracteres<br>• Máximo 100 caracteres | `miPassword123` | `12345` ❌ (muy corta) |

**Tipo de Dato:**
- Ambos campos son **string**

**Validaciones Adicionales en Backend:**
- ✅ Usuario debe existir en el sistema (busca en usuarios y empleados)
- ✅ Contraseña debe coincidir (se compara con hash SHA256)
- ✅ Usuario debe estar activo

---

## 🔧 CONFIGURACIÓN TÉCNICA

### Habilitación de Validaciones Automáticas

**Archivo:** `Program.cs`

```csharp
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        // Habilitar respuestas automáticas de validación
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value.Errors.Count > 0)
                .Select(e => new 
                {
                    Campo = e.Key,
                    Errores = e.Value.Errors.Select(x => x.ErrorMessage).ToArray()
                }).ToList();

            return new BadRequestObjectResult(new
            {
                message = "Errores de validación",
                errors = errors
            });
        };
    });
```

### Data Annotations Utilizadas

| Anotación | Propósito | Ejemplo |
|-----------|-----------|---------|
| `[Required]` | Campo obligatorio | `[Required(ErrorMessage = "...")]` |
| `[MinLength]` | Longitud mínima | `[MinLength(3, ErrorMessage = "...")]` |
| `[MaxLength]` | Longitud máxima | `[MaxLength(100, ErrorMessage = "...")]` |
| `[Range]` | Rango numérico | `[Range(0.01, 1000000, ErrorMessage = "...")]` |
| `[EmailAddress]` | Formato email válido | `[EmailAddress(ErrorMessage = "...")]` |
| `[RegularExpression]` | Patrón personalizado | `[RegularExpression(@"^[a-zA-Z]+$", ErrorMessage = "...")]` |

---

## 📊 RESUMEN DE TIPOS DE DATOS

| Modelo | Campo | Tipo de Dato | Solo Texto | Solo Números | Permite Decimales |
|--------|-------|--------------|-----------|--------------|------------------|
| **Usuario** | NombreUsuario | string | ❌ | ❌ | N/A |
| Usuario | Password | string | ❌ | ❌ | N/A |
| Usuario | CorreoElectronico | string | ❌ | ❌ | N/A |
| Usuario | NombreCompleto | string | ✅ | ❌ | N/A |
| **Empleado** | PorcentajeComision | double | N/A | ✅ | ✅ |
| **Producto** | Nombre | string | ❌ | ❌ | N/A |
| Producto | Precio | double | N/A | ✅ | ✅ |
| Producto | Stock | int | N/A | ✅ | ❌ |
| **Servicio** | Nombre | string | ❌ | ❌ | N/A |
| Servicio | PrecioBase | double | N/A | ✅ | ✅ |
| **Solicitud** | Descripcion | string | ✅ | ✅ | N/A |
| **Abono** | Monto | double | N/A | ✅ | ✅ |
| Abono | MetodoPago | string | ✅ | ❌ | N/A |

---

## ✅ VALIDACIONES IMPLEMENTADAS POR CASO DE USO

| Caso de Uso | Validaciones Implementadas |
|-------------|---------------------------|
| CU-01: Registrarse | ✅ Nombre usuario alfanumérico<br>✅ Password mínimo 6 caracteres<br>✅ Email formato válido<br>✅ Nombre solo letras<br>✅ Únicos en sistema |
| CU-02: Iniciar Sesión | ✅ Campos obligatorios<br>✅ Longitud mínima<br>✅ Usuario existe y activo |
| CU-03: Solicitar Servicio | ✅ Descripción mínimo 10 caracteres<br>✅ Cliente ID válido |
| CU-07: Pagar Factura | ✅ Monto mayor a 0<br>✅ Monto no excede saldo<br>✅ Método de pago válido |
| CU-10: Generar Factura | ✅ Stock suficiente<br>✅ Precios válidos<br>✅ Cantidades positivas |
| CU-11: Gestionar Empleados | ✅ Usuario único<br>✅ Correo único<br>✅ Comisión 0-100%<br>✅ Nombre solo letras |
| CU-12: Gestionar Productos | ✅ Nombre alfanumérico<br>✅ Precio positivo<br>✅ Stock no negativo |
| CU-13: Gestionar Servicios | ✅ Nombre alfanumérico<br>✅ Precio base positivo |

---

## 🎯 EJEMPLOS DE USO EN POSTMAN/THUNDER CLIENT

### Crear Producto (Correcto)
```json
POST /api/producto
{
  "Nombre": "Aceite Mobil 1 10W-40",
  "Descripcion": "Aceite sintético de alta calidad",
  "Precio": 450.50,
  "Stock": 25
}
```

### Crear Producto (Incorrecto)
```json
POST /api/producto
{
  "Nombre": "A",  // ❌ Muy corto
  "Descripcion": "",
  "Precio": -100,  // ❌ Negativo
  "Stock": -5  // ❌ Negativo
}

// Respuesta:
{
  "message": "Errores de validación",
  "errors": [
    {
      "Campo": "Nombre",
      "Errores": ["El nombre debe tener al menos 2 caracteres"]
    },
    {
      "Campo": "Precio",
      "Errores": ["El precio debe estar entre 0.01 y 1,000,000"]
    },
    {
      "Campo": "Stock",
      "Errores": ["El stock debe estar entre 0 y 100,000"]
    }
  ]
}
```

---

*Documento generado basándose en las validaciones implementadas en el sistema ProyectoWeb - Taller Mecánico*
