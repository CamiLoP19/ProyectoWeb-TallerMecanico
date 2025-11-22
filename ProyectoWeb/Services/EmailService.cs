using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using ProyectoWeb.Models;
using System.Drawing;
using System.Drawing.Imaging;
using ZXing;
using ZXing.Common;

namespace ProyectoWeb.Services
{
    public class EmailService
    {
        private readonly ILogger<EmailService> _logger;
        private readonly IConfiguration _configuration;
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _senderEmail;
        private readonly string _senderPassword;
        private readonly string _senderName;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _logger = logger;
            _configuration = configuration;

            // Configuración de SMTP desde appsettings.json
            _smtpHost = configuration["EmailSettings:SmtpHost"] ?? "smtp.gmail.com";
            _smtpPort = int.Parse(configuration["EmailSettings:SmtpPort"] ?? "587");
            _senderEmail = configuration["EmailSettings:SenderEmail"] ?? "";
            _senderPassword = configuration["EmailSettings:SenderPassword"] ?? "";
            _senderName = configuration["EmailSettings:SenderName"] ?? "Taller ProyectoWeb";

            // Log de configuración (sin mostrar password completo)
            _logger.LogInformation("EmailService inicializado - Host: {Host}, Port: {Port}, Email: {Email}", 
                _smtpHost, _smtpPort, _senderEmail);
        }
        public async Task<bool> EnviarEmailRecuperacionAsync(string emailDestino, string token, string nombreUsuario = "")
        {
            try
            {
                _logger.LogInformation("Enviando email de recuperación a {Email}", emailDestino);

                // Validar configuración de email
                if (string.IsNullOrEmpty(_senderEmail) || string.IsNullOrEmpty(_senderPassword))
                {
                    _logger.LogWarning("Configuración de email no encontrada");
                    return false;
                }

                // Obtener la URL base de la aplicación
                var baseUrl = _configuration["AppSettings:BaseUrl"] ?? "https://localhost:5000";
                var recoveryUrl = $"{baseUrl}/restablecer-password?token={token}";

                // Crear mensaje
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress(_senderName, _senderEmail));
                message.To.Add(new MailboxAddress(nombreUsuario, emailDestino));
                message.Subject = "🔑 Recuperación de Contraseña - Taller ProyectoWeb";

                // Crear cuerpo HTML
                var bodyBuilder = new BodyBuilder
                {
                    HtmlBody = CrearPlantillaRecuperacionHtml(nombreUsuario, recoveryUrl, token)
                };

                message.Body = bodyBuilder.ToMessageBody();

                // Enviar email
                using (var client = new SmtpClient())
                {
                    _logger.LogInformation("Conectando a SMTP {Host}:{Port}", _smtpHost, _smtpPort);
                    await client.ConnectAsync(_smtpHost, _smtpPort, SecureSocketOptions.StartTls);
                    
                    _logger.LogDebug("Autenticando con {Email}", _senderEmail);
                    await client.AuthenticateAsync(_senderEmail, _senderPassword);
                    
                    _logger.LogDebug("Enviando mensaje...");
                    await client.SendAsync(message);
                    await client.DisconnectAsync(true);
                }

                _logger.LogInformation("Email de recuperación enviado exitosamente a {Email}", emailDestino);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de recuperación a {Email}", emailDestino);
                return false;
            }
        }

        // ============================================
        // 🆕 PLANTILLA HTML PARA RECUPERACIÓN
        // ============================================
        private string CrearPlantillaRecuperacionHtml(string nombreUsuario, string recoveryUrl, string token)
        {
            var html = $@"
<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Recuperación de Contraseña</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }}
        .container {{
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        .header h1 {{
            margin: 0;
            font-size: 28px;
        }}
        .content {{
            padding: 30px;
        }}
        .content h2 {{
            color: #667eea;
            margin-top: 0;
        }}
        .content p {{
            margin: 15px 0;
            font-size: 16px;
        }}
        .button {{
            display: inline-block;
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            font-size: 16px;
            margin: 20px 0;
        }}
        .button:hover {{
            opacity: 0.9;
        }}
        .warning-box {{
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }}
        .warning-box p {{
            margin: 5px 0;
            color: #856404;
        }}
        .token-box {{
            background-color: #f8f9fa;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
            font-family: 'Courier New', monospace;
        }}
        .token-box code {{
            font-size: 14px;
            color: #667eea;
            word-break: break-all;
        }}
        .footer {{
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            color: #666;
            font-size: 14px;
        }}
        .footer p {{
            margin: 5px 0;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🔑 Recuperación de Contraseña</h1>
        </div>

        <div class='content'>
            <h2>Hola{(!string.IsNullOrEmpty(nombreUsuario) ? $" {nombreUsuario}" : "")},</h2>
            
            <p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en <strong>Taller ProyectoWeb</strong>.</p>
            
            <p>Si realizaste esta solicitud, haz clic en el siguiente botón para crear una nueva contraseña:</p>
            
            <div style='text-align: center;'>
                <a href='{recoveryUrl}' class='button'>
                    Restablecer mi contraseña
                </a>
            </div>

            <p style='margin-top: 20px; font-size: 14px; color: #666;'>
                O copia y pega este enlace en tu navegador:
            </p>
            <div class='token-box'>
                <code>{recoveryUrl}</code>
            </div>

            <div class='warning-box'>
                <p><strong>⚠️ Importante:</strong></p>
                <p>• Este enlace es válido por <strong>1 hora</strong></p>
                <p>• Si no solicitaste este cambio, ignora este correo</p>
                <p>• Tu contraseña actual permanecerá sin cambios</p>
            </div>

            <p style='margin-top: 30px; color: #666; font-size: 14px;'>
                Si no solicitaste restablecer tu contraseña, es posible que alguien haya ingresado tu correo por error. 
                Tu cuenta está segura y no necesitas hacer nada.
            </p>
        </div>

        <div class='footer'>
            <p><strong>Taller ProyectoWeb</strong></p>
            <p>Este es un correo automático, por favor no responder</p>
            <p>¿Necesitas ayuda? Contáctanos: {_senderEmail}</p>
        </div>
    </div>
</body>
</html>";

            return html;
        }

        // ============================================
        // MÉTODO EXISTENTE: ENVIAR FACTURA
        // ============================================
        /// <summary>
        /// Envía una factura por correo electrónico con código de barras
        /// </summary>
        public async Task<bool> EnviarFacturaPorCorreoAsync(Factura factura, string emailDestino)
        {
            try
            {
                _logger.LogInformation("Intentando enviar factura {NumeroFactura} a {Email}", 
                    factura.NumeroFactura, emailDestino);

                // Validar configuración de email
                if (string.IsNullOrEmpty(_senderEmail) || string.IsNullOrEmpty(_senderPassword))
                {
                    _logger.LogWarning("Configuración de email no encontrada. Email: {Email}, Password: {HasPassword}", 
                        _senderEmail, !string.IsNullOrEmpty(_senderPassword));
                    return false;
                }

                // Generar código de barras
                var codigoBarrasBase64 = GenerarCodigoBarras(factura.NumeroFactura);

                // Crear mensaje
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress(_senderName, _senderEmail));
                message.To.Add(new MailboxAddress(factura.ClienteNombre, emailDestino));
                message.Subject = $"Factura {factura.NumeroFactura} - Taller";

                // Crear cuerpo HTML
                var bodyBuilder = new BodyBuilder
                {
                    HtmlBody = CrearPlantillaFacturaHtml(factura, codigoBarrasBase64)
                };

                message.Body = bodyBuilder.ToMessageBody();

                // Enviar email
                using (var client = new SmtpClient())
                {
                    _logger.LogInformation("Conectando a SMTP {Host}:{Port}", _smtpHost, _smtpPort);
                    await client.ConnectAsync(_smtpHost, _smtpPort, SecureSocketOptions.StartTls);
                    
                    _logger.LogDebug("Autenticando con {Email}", _senderEmail);
                    await client.AuthenticateAsync(_senderEmail, _senderPassword);
                    
                    _logger.LogDebug("Enviando mensaje...");
                    await client.SendAsync(message);
                    await client.DisconnectAsync(true);
                    _logger.LogInformation("Mensaje enviado exitosamente");
                }

                _logger.LogInformation("Factura {NumeroFactura} enviada por correo a {Email}", 
                    factura.NumeroFactura, emailDestino);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar factura {NumeroFactura} por correo a {Email}", 
                    factura.NumeroFactura, emailDestino);
                return false;
            }
        }

        /// <summary>
        /// Genera un código de barras en formato Base64
        /// </summary>
        private string GenerarCodigoBarras(string texto)
        {
            try
            {
                var writer = new BarcodeWriterPixelData
                {
                    Format = BarcodeFormat.CODE_128,
                    Options = new EncodingOptions
                    {
                        Height = 100,
                        Width = 300,
                        Margin = 10
                    }
                };

                var pixelData = writer.Write(texto);

                using (var bitmap = new Bitmap(pixelData.Width, pixelData.Height, PixelFormat.Format32bppRgb))
                {
                    var bitmapData = bitmap.LockBits(
                        new Rectangle(0, 0, pixelData.Width, pixelData.Height),
                        ImageLockMode.WriteOnly,
                        PixelFormat.Format32bppRgb);

                    try
                    {
                        System.Runtime.InteropServices.Marshal.Copy(
                            pixelData.Pixels, 0, bitmapData.Scan0, pixelData.Pixels.Length);
                    }
                    finally
                    {
                        bitmap.UnlockBits(bitmapData);
                    }

                    using (var stream = new MemoryStream())
                    {
                        bitmap.Save(stream, ImageFormat.Png);
                        var bytes = stream.ToArray();
                        return Convert.ToBase64String(bytes);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al generar código de barras");
                return string.Empty;
            }
        }

        /// <summary>
        /// Crea la plantilla HTML para el email de la factura
        /// </summary>
        private string CrearPlantillaFacturaHtml(Factura factura, string codigoBarrasBase64)
        {
            var html = $@"
<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Factura {factura.NumeroFactura}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }}
        .container {{
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        .header h1 {{
            margin: 0;
            font-size: 28px;
        }}
        .content {{
            padding: 30px;
        }}
        .factura-info {{
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }}
        .factura-info p {{
            margin: 8px 0;
        }}
        .barcode {{
            text-align: center;
            margin: 20px 0;
            padding: 20px;
            background-color: white;
            border: 2px solid #667eea;
            border-radius: 8px;
        }}
        .barcode img {{
            max-width: 100%;
            height: auto;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }}
        th {{
            background-color: #667eea;
            color: white;
            padding: 12px;
            text-align: left;
        }}
        td {{
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }}
        .total-section {{
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }}
        .total-row {{
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
            font-size: 18px;
        }}
        .total-row.final {{
            font-weight: bold;
            font-size: 24px;
            color: #667eea;
            border-top: 2px solid #667eea;
            padding-top: 10px;
        }}
        .estado {{
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            margin-top: 10px;
        }}
        .estado.pagada {{
            background-color: #28a745;
            color: white;
        }}
        .estado.pendiente {{
            background-color: #ffc107;
            color: #333;
        }}
        .footer {{
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            color: #666;
            font-size: 14px;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🔧 FACTURA DE SERVICIO</h1>
            <p>Taller ProyectoWeb</p>
        </div>

        <div class='content'>
            <div class='barcode'>
                <h2 style='color: #667eea; margin-top: 0;'>{factura.NumeroFactura}</h2>
                {(string.IsNullOrEmpty(codigoBarrasBase64) ? "" : $"<img src='data:image/png;base64,{codigoBarrasBase64}' alt='Código de Barras' />")}
            </div>

            <div class='factura-info'>
                <h3 style='color: #667eea; margin-top: 0;'>Información de la Factura</h3>
                <p><strong>Fecha de Emisión:</strong> {factura.FechaEmision.ToLocalTime():dd/MM/yyyy HH:mm}</p>
                <p><strong>Cliente:</strong> {factura.ClienteNombre}</p>
                <p><strong>Empleado:</strong> {factura.EmpleadoNombre}</p>
                <p><strong>Estado:</strong> <span class='estado {(factura.Pagada ? "pagada" : "pendiente")}'>{(factura.Pagada ? "PAGADA" : "PENDIENTE")}</span></p>
            </div>

            <h3 style='color: #667eea;'>Servicio Realizado</h3>
            <div style='background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>
                <p style='margin: 0;'><strong>{factura.ServicioNombre}</strong></p>
                <p style='margin: 5px 0 0 0; text-align: right; font-size: 18px; color: #667eea;'><strong>${factura.PrecioServicio:N2}</strong></p>
            </div>

            {(factura.Detalles != null && factura.Detalles.Any() ? $@"
            <h3 style='color: #667eea;'>Productos Utilizados</h3>
            <table>
                <thead>
                    <tr>
                        <th>Producto</th>
                        <th style='text-align: center;'>Cantidad</th>
                        <th style='text-align: right;'>Precio Unit.</th>
                        <th style='text-align: right;'>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    {string.Join("", factura.Detalles.Select(d => $@"
                    <tr>
                        <td>{d.ProductoNombre}</td>
                        <td style='text-align: center;'>{d.Cantidad}</td>
                        <td style='text-align: right;'>${d.PrecioUnitario:N2}</td>
                        <td style='text-align: right;'>${d.Subtotal:N2}</td>
                    </tr>"))}
                </tbody>
            </table>" : "")}

            <div class='total-section'>
                <div class='total-row'>
                    <span>Subtotal Servicio:</span>
                    <span>${factura.PrecioServicio:N2}</span>
                </div>
                <div class='total-row'>
                    <span>Subtotal Productos:</span>
                    <span>${factura.SubtotalProductos:N2}</span>
                </div>
                <div class='total-row final'>
                    <span>TOTAL:</span>
                    <span>${factura.Total:N2}</span>
                </div>
                {(!factura.Pagada ? $@"
                <div class='total-row' style='color: #dc3545;'>
                    <span>Saldo Pendiente:</span>
                    <span>${factura.Saldo:N2}</span>
                </div>" : "")}
            </div>

            <div style='margin-top: 30px; padding: 20px; background-color: #e7f3ff; border-left: 4px solid #667eea; border-radius: 4px;'>
                <p style='margin: 0;'><strong>📧 ¿Necesitas ayuda?</strong></p>
                <p style='margin: 5px 0 0 0;'>Contáctanos al correo: {_senderEmail}</p>
            </div>
        </div>

        <div class='footer'>
            <p>Gracias por confiar en nuestro taller</p>
            <p>Este es un correo automático, por favor no responder</p>
        </div>
    </div>
</body>
</html>";

            return html;
        }
    }
}