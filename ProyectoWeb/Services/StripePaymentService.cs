using Stripe;
using Stripe.Checkout;
using ProyectoWeb.Models;

namespace ProyectoWeb.Services;

public class StripePaymentService
{
    private readonly ILogger<StripePaymentService> _logger;
    private readonly string _stripePublishableKey;
    private readonly string _webhookSecret;

    public StripePaymentService(
        IConfiguration configuration,
        ILogger<StripePaymentService> logger)
    {
        _logger = logger;
        
        var stripeSecretKey = configuration["Stripe:SecretKey"] ?? "";
        _stripePublishableKey = configuration["Stripe:PublishableKey"] ?? "";
        _webhookSecret = configuration["Stripe:WebhookSecret"] ?? "";
        
        StripeConfiguration.ApiKey = stripeSecretKey;
    }

    /// <summary>
    /// Crea una sesión de pago de Stripe para una factura
    /// </summary>
    public async Task<string> CrearSesionPagoAsync(Factura factura, string correoCliente, string urlExito, string urlCancelacion)
    {
        try
        {
            var opciones = new SessionCreateOptions
            {
                PaymentMethodTypes = new List<string>
                {
                    "card",  // Tarjetas de crédito/débito
                    // "oxxo" y "spei" requieren activación en el dashboard de Stripe
                },
                LineItems = new List<SessionLineItemOptions>
                {
                    new SessionLineItemOptions
                    {
                        PriceData = new SessionLineItemPriceDataOptions
                        {
                            UnitAmount = (long)(factura.Total * 100), // Stripe usa centavos
                            Currency = "mxn",
                            ProductData = new SessionLineItemPriceDataProductDataOptions
                            {
                                Name = $"Factura #{factura.Id}",
                                Description = $"Pago de servicios de taller mecánico",
                            },
                        },
                        Quantity = 1,
                    },
                },
                Mode = "payment",
                SuccessUrl = urlExito,
                CancelUrl = urlCancelacion,
                CustomerEmail = correoCliente,
                Metadata = new Dictionary<string, string>
                {
                    { "facturaId", factura.Id ?? "" },
                    { "clienteId", factura.ClienteId ?? "" },
                },
                ExpiresAt = DateTime.UtcNow.AddHours(24), // La sesión expira en 24 horas
            };

            var servicio = new SessionService();
            var sesion = await servicio.CreateAsync(opciones);

            _logger.LogInformation("Sesión de pago creada: {SesionId} para factura {FacturaId}", sesion.Id, factura.Id);
            
            return sesion.Url; // URL de pago de Stripe
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error de Stripe al crear sesión de pago");
            throw new InvalidOperationException("Error al crear sesión de pago", ex);
        }
    }

    /// <summary>
    /// Verifica el estado de un pago
    /// </summary>
    public async Task<(bool Exitoso, string Estado, double Monto, string? FacturaId)> VerificarEstadoPagoAsync(string sesionId)
    {
        try
        {
            var servicio = new SessionService();
            var sesion = await servicio.GetAsync(sesionId);

            var exitoso = sesion.PaymentStatus == "paid";
            var monto = (double)(sesion.AmountTotal ?? 0) / 100; // Convertir de centavos a pesos
            var facturaId = sesion.Metadata?.ContainsKey("facturaId") ?? false ? sesion.Metadata["facturaId"] : null;

            _logger.LogInformation("Estado de pago verificado - Sesión: {SesionId}, Estado: {PaymentStatus}, Exitoso: {Exitoso}", sesionId, sesion.PaymentStatus, exitoso);

            return (exitoso, sesion.PaymentStatus, monto, facturaId);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al verificar estado de pago");
            throw new InvalidOperationException("Error al verificar pago", ex);
        }
    }

    /// <summary>
    /// Obtiene la información de un pago completado
    /// </summary>
    public async Task<PaymentIntent?> ObtenerDetallePagoAsync(string paymentIntentId)
    {
        try
        {
            var servicio = new PaymentIntentService();
            var pago = await servicio.GetAsync(paymentIntentId);
            
            return pago;
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al obtener detalle de pago");
            return null;
        }
    }

    /// <summary>
    /// Verifica la firma del webhook de Stripe
    /// </summary>
    public Event? VerificarWebhook(string json, string firmaStripe)
    {
        try
        {
            var evento = EventUtility.ConstructEvent(json, firmaStripe, _webhookSecret);
            return evento;
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al verificar webhook");
            return null;
        }
    }

    public string ObtenerPublicKey()
    {
        return _stripePublishableKey;
    }
}
