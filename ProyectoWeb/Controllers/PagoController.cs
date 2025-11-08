using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Services;
using ProyectoWeb.Models;
using Stripe;

namespace ProyectoWeb.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PagoController : ControllerBase
{
    private readonly StripePaymentService _stripeService;
    private readonly FacturaService _facturaService;
    private readonly AbonoService _abonoService;
    private readonly ILogger<PagoController> _logger;

    public PagoController(
        StripePaymentService stripeService,
        FacturaService facturaService,
        AbonoService abonoService,
        ILogger<PagoController> logger)
    {
        _stripeService = stripeService;
        _facturaService = facturaService;
        _abonoService = abonoService;
        _logger = logger;
    }

    [HttpPost("crear-sesion/{facturaId}")]
    public async Task<IActionResult> CrearSesionPago(string facturaId, [FromBody] DatosPagoRequest request)
    {
        try
        {
            _logger.LogInformation($"Creando sesión de pago para factura: {facturaId}");
            
            var factura = await _facturaService.ObtenerFacturaPorIdAsync(facturaId);
            if (factura == null)
            {
                _logger.LogWarning($"Factura no encontrada: {facturaId}");
                return NotFound(new { mensaje = "Factura no encontrada" });
            }

            if (factura.Pagada)
            {
                _logger.LogWarning($"Factura ya pagada: {facturaId}");
                return BadRequest(new { mensaje = "Esta factura ya está pagada" });
            }

            // Crear URLs de éxito y cancelación
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            var urlExito = $"{baseUrl}/pago/exitoso?session_id={{CHECKOUT_SESSION_ID}}";
            var urlCancelacion = $"{baseUrl}/pago/cancelado?facturaId={facturaId}";

            _logger.LogInformation($"URLs creadas - Éxito: {urlExito}, Cancelación: {urlCancelacion}");
            _logger.LogInformation($"Correo cliente: {request.CorreoCliente}");

            var urlPago = await _stripeService.CrearSesionPagoAsync(
                factura,
                request.CorreoCliente,
                urlExito,
                urlCancelacion
            );

            _logger.LogInformation($"Sesión creada exitosamente, URL: {urlPago}");
            return Ok(new { url = urlPago });
        }
        catch (Exception ex)
        {
            _logger.LogError($"EXCEPCIÓN al crear sesión de pago: {ex.Message}");
            _logger.LogError($"StackTrace: {ex.StackTrace}");
            if (ex.InnerException != null)
            {
                _logger.LogError($"InnerException: {ex.InnerException.Message}");
            }
            return StatusCode(500, new { mensaje = $"Error al procesar el pago: {ex.Message}" });
        }
    }

    [HttpGet("verificar/{sesionId}")]
    public async Task<IActionResult> VerificarPago(string sesionId)
    {
        try
        {
            var (exitoso, estado, monto, facturaId) = await _stripeService.VerificarEstadoPagoAsync(sesionId);

            return Ok(new
            {
                exitoso,
                estado,
                monto,
                facturaId
            });
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al verificar pago: {ex.Message}");
            return StatusCode(500, new { mensaje = $"Error al verificar pago: {ex.Message}" });
        }
    }

    /// <summary>
    /// Webhook de Stripe para notificaciones de pagos
    /// </summary>
    [HttpPost("webhook")]
    public async Task<IActionResult> WebhookStripe()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var firmaStripe = Request.Headers["Stripe-Signature"].ToString();

        try
        {
            var evento = _stripeService.VerificarWebhook(json, firmaStripe);
            if (evento == null)
            {
                return BadRequest(new { mensaje = "Firma de webhook inválida" });
            }

            _logger.LogInformation($"Webhook recibido: {evento.Type}");

            // Procesar diferentes tipos de eventos
            switch (evento.Type)
            {
                case "checkout.session.completed":
                    await ProcesarPagoExitoso(evento);
                    break;

                case "checkout.session.expired":
                    _logger.LogInformation($"Sesión de pago expiró: {evento.Id}");
                    break;

                case "payment_intent.payment_failed":
                    _logger.LogWarning($"Pago fallido: {evento.Id}");
                    break;
            }

            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error procesando webhook: {ex.Message}");
            return StatusCode(500);
        }
    }

    private async Task ProcesarPagoExitoso(Event evento)
    {
        try
        {
            var sesion = evento.Data.Object as Stripe.Checkout.Session;
            if (sesion == null) return;

            var facturaId = sesion.Metadata["facturaId"];
            var monto = (double)(sesion.AmountTotal ?? 0) / 100;

            _logger.LogInformation($"Procesando pago exitoso para factura: {facturaId}, monto: {monto}");

            // Registrar el abono
            var abono = new Abono
            {
                Id = Guid.NewGuid().ToString(),
                FacturaId = facturaId,
                Monto = monto,
                FechaAbono = DateTime.Now,
                MetodoPago = "Stripe - " + (sesion.PaymentMethodTypes?.FirstOrDefault() ?? "Tarjeta"),
                Observaciones = $"Pago procesado vía Stripe. Sesión: {sesion.Id}"
            };

            await _abonoService.RegistrarAbonoAsync(abono);

            _logger.LogInformation($"Abono registrado exitosamente para factura {facturaId}");
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al procesar pago exitoso: {ex.Message}");
        }
    }

    [HttpGet("public-key")]
    public IActionResult ObtenerPublicKey()
    {
        return Ok(new { publicKey = _stripeService.ObtenerPublicKey() });
    }
}

public class DatosPagoRequest
{
    public string CorreoCliente { get; set; } = "";
}
