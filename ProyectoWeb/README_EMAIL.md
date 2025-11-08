# 📧 Configuración de Email para el Sistema de Facturas

## ⚠️ Estado Actual
El sistema está configurado para enviar facturas automáticamente por correo electrónico, pero **necesita configuración**.

## 🔧 Configuración Requerida

### 1. Obtener Contraseña de Aplicación de Gmail

1. **Habilitar 2FA en tu cuenta de Gmail**:
   - Ve a tu cuenta de Google: https://myaccount.google.com/security
   - Busca "Verificación en dos pasos" y actívala

2. **Generar una Contraseña de Aplicación**:
   - Ve a: https://myaccount.google.com/apppasswords
   - Selecciona "Correo" y "Windows Computer"
   - Copia la contraseña de 16 caracteres que aparece

### 2. Configurar appsettings.json

Abre el archivo `appsettings.json` y actualiza la sección `EmailSettings`:

```json
"EmailSettings": {
  "SmtpHost": "smtp.gmail.com",
  "SmtpPort": "587",
  "SenderEmail": "tuemail@gmail.com",           // ← Cambia esto
  "SenderPassword": "xxxx xxxx xxxx xxxx",      // ← Pega aquí la contraseña de app
  "SenderName": "Taller ProyectoWeb"
}
```

### 3. Ejemplo Completo

```json
{
  "EmailSettings": {
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": "587",
    "SenderEmail": "tallermecanico@gmail.com",
    "SenderPassword": "abcd efgh ijkl mnop",
    "SenderName": "Taller Mecánico Don José"
  }
}
```

## 📨 ¿Cuándo se Envían los Emails?

El sistema envía automáticamente un email en estos casos:

1. **Cuando se genera una factura desde una solicitud** (GenerarFacturaAsync)
   - El empleado completa un servicio
   - Se genera la factura
   - 📧 **Email automático** al cliente con:
     - Detalles de la factura
     - Código de barras
     - Lista de productos
     - Total y saldo pendiente

2. **Cuando se crea una factura directamente** (POST /api/factura)
   - Si se proporciona `ClienteEmail` en el body
   - 📧 **Email automático** al cliente

## 🧪 Probar el Envío de Email

### Opción 1: Generar una Factura desde el Sistema
1. Inicia sesión como empleado
2. Completa un servicio/solicitud
3. Genera la factura
4. El cliente recibirá el email automáticamente

### Opción 2: Verificar Logs
Los logs te dirán si el email se envió correctamente:

```
✅ Factura F-202510020093159 enviada por correo a cliente@email.com
❌ Configuración de email no encontrada. No se puede enviar el correo.
```

## 🚫 Solución de Problemas

### Error: "Configuración de email no encontrada"
- **Causa**: El archivo `appsettings.json` tiene valores de ejemplo
- **Solución**: Actualiza con tu email y contraseña de aplicación real

### Error: "Authentication failed"
- **Causa**: Contraseña incorrecta o 2FA no habilitada
- **Solución**: 
  1. Verifica que 2FA esté activo
  2. Genera una nueva contraseña de aplicación
  3. Copia exactamente los 16 caracteres (con espacios o sin espacios)

### Error: "SMTP connection failed"
- **Causa**: Puerto o host incorrectos
- **Solución**: Usa `smtp.gmail.com` y puerto `587`

### No recibo el email
1. Revisa la carpeta de SPAM
2. Verifica que el email del cliente sea correcto en Firebase
3. Revisa los logs de la aplicación

## 📝 Notas Importantes

- ⚠️ **NUNCA subas el archivo `appsettings.json` con credenciales reales a GitHub**
- 🔒 Usa variables de entorno en producción
- 📧 Los emails se envían de forma asíncrona (no bloquean la respuesta)
- ⏱️ Si el envío falla, se registra como advertencia pero no detiene el proceso

## 🔐 Seguridad en Producción

Para producción, usa variables de entorno:

```bash
$env:EmailSettings__SenderEmail = "tuemail@gmail.com"
$env:EmailSettings__SenderPassword = "tu-password-app"
```

O en Azure App Service:
- Ve a Configuration → Application Settings
- Agrega: `EmailSettings:SenderEmail`
- Agrega: `EmailSettings:SenderPassword`

## ✨ Plantilla del Email

El email incluye:
- 🎨 Diseño HTML profesional
- 📊 Tabla de productos
- 📷 Código de barras generado automáticamente
- 💰 Totales y saldo pendiente
- 🎯 Badge de estado (PAGADA/PENDIENTE)

---

**¿Necesitas ayuda?** Revisa los logs de la aplicación para más detalles.
