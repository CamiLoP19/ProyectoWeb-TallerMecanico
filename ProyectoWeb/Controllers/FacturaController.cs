using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Models;
using ProyectoWeb.Services;
using ProyectoWeb.Data;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ProyectoWeb.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FacturaController : ControllerBase
    {
        private readonly FacturaService _facturaService;
        private readonly EmailService _emailService;
        private readonly ILogger<FacturaController> _logger;

        public FacturaController(
            FacturaService facturaService, 
            EmailService emailService,
            ILogger<FacturaController> logger)
        {
            _facturaService = facturaService;
            _emailService = emailService;
            _logger = logger;
        }

        /// <summary>
        /// GET: api/factura
        /// Obtiene todas las facturas
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<Factura>>> ObtenerFacturas()
        {
            try
            {
                var facturas = await _facturaService.ObtenerFacturasAsync();
                return Ok(facturas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener facturas");
                return StatusCode(500, new { message = ex.Message });
            }
        }

        /// <summary>
        /// GET: api/factura/cliente/{clienteId}
        /// Obtiene facturas de un cliente específico
        /// </summary>
        [HttpGet("cliente/{clienteId}")]
        public async Task<ActionResult<List<Factura>>> ObtenerFacturasPorCliente(string clienteId)
        {
            try
            {
                var facturas = await _facturaService.ObtenerFacturasPorClienteAsync(clienteId);
                return Ok(facturas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener facturas del cliente {ClienteId}", clienteId);
                return StatusCode(500, new { message = "Error al obtener facturas" });
            }
        }

        /// <summary>
        /// GET: api/factura/{id}
        /// Obtiene una factura específica por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<Factura>> ObtenerFactura(string id)
        {
            try
            {
                var factura = await _facturaService.ObtenerFacturaPorIdAsync(id);
                if (factura == null)
                {
                    return NotFound(new { message = "Factura no encontrada" });
                }
                return Ok(factura);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener factura {FacturaId}", id);
                return StatusCode(500, new { message = "Error al obtener factura" });
            }
        }

        /// <summary>
        /// POST: api/factura
        /// Crea una nueva factura directamente
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<Factura>> CrearFactura([FromBody] Factura factura)
        {
            try
            {
                _logger.LogInformation("Creando factura para cliente {ClienteId}", factura.ClienteId);
                
                var facturaCreada = await _facturaService.CrearFacturaAsync(factura);
                
                // Intentar enviar la factura por correo (en segundo plano pero con logs completos)
                _ = Task.Run(async () =>
                {
                    try
                    {
                        _logger.LogInformation("Intentando enviar factura {NumeroFactura} por correo...", facturaCreada.NumeroFactura);
                        
                        // Si no viene el email, intentar obtenerlo de Firebase
                        string emailDestino = factura.ClienteEmail;
                        if (string.IsNullOrEmpty(emailDestino))
                        {
                            _logger.LogInformation("Email no proporcionado, obteniendo desde Firebase para cliente {ClienteId}", factura.ClienteId);
                            var firebaseService = HttpContext.RequestServices.GetRequiredService<FirebaseService>();
                            var usuariosCollection = firebaseService.GetCollection("usuarios");
                            var clienteDoc = await usuariosCollection.Document(factura.ClienteId).GetSnapshotAsync();
                            
                            if (clienteDoc.Exists)
                            {
                                emailDestino = clienteDoc.GetValue<string>("CorreoElectronico");
                                _logger.LogInformation("Email del cliente encontrado: {Email}", emailDestino);
                            }
                            else
                            {
                                _logger.LogWarning("No se encontró el cliente {ClienteId} en Firebase", factura.ClienteId);
                            }
                        }
                        
                        if (!string.IsNullOrEmpty(emailDestino))
                        {
                            var enviado = await _emailService.EnviarFacturaPorCorreoAsync(facturaCreada, emailDestino);
                            if (enviado)
                            {
                                _logger.LogInformation("Factura {NumeroFactura} enviada exitosamente a {Email}", facturaCreada.NumeroFactura, emailDestino);
                            }
                            else
                            {
                                _logger.LogWarning("No se pudo enviar la factura {NumeroFactura}", facturaCreada.NumeroFactura);
                            }
                        }
                        else
                        {
                            _logger.LogWarning("No se pudo obtener el email del cliente para la factura {NumeroFactura}", facturaCreada.NumeroFactura);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error al enviar email de la factura {NumeroFactura}", facturaCreada.NumeroFactura);
                    }
                });
                
                return CreatedAtAction(nameof(ObtenerFactura), new { id = facturaCreada.Id }, facturaCreada);
            }
            catch (ArgumentException ex)
            {
                _logger.LogError(ex, "Error de validación al crear factura");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear factura");
                return StatusCode(500, new { message = ex.Message });
            }
        }

        /// <summary>
        /// POST: api/factura/generar
        /// Genera una nueva factura a partir de una solicitud
        /// </summary>
        [HttpPost("generar")]
        public async Task<ActionResult<Factura>> GenerarFactura([FromBody] GenerarFacturaDto dto)
        {
            try
            {
                var factura = await _facturaService.GenerarFacturaAsync(
                    dto.SolicitudId, 
                    dto.Detalles, 
                    dto.PorcentajeComision);
                
                return CreatedAtAction(nameof(ObtenerFactura), new { id = factura.Id }, factura);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al generar factura");
                return StatusCode(500, new { message = ex.Message });
            }
        }

        /// <summary>
        /// POST: api/factura/{id}/abono
        /// Registra un abono en una factura
        /// </summary>
        [HttpPost("{id}/abono")]
        public async Task<IActionResult> RegistrarAbono(string id, [FromBody] AbonoDto dto)
        {
            try
            {
                await _facturaService.RegistrarAbonoEnFacturaAsync(id, dto.Monto);
                return Ok(new { message = "Abono registrado correctamente" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar abono en factura {FacturaId}", id);
                return StatusCode(500, new { message = "Error al registrar abono" });
            }
        }

        /// <summary>
        /// POST: api/factura/{id}/enviar-email
        /// Envía una factura por correo electrónico (endpoint de prueba)
        /// </summary>
        [HttpPost("{id}/enviar-email")]
        public async Task<ActionResult> EnviarFacturaPorEmail(string id, [FromBody] EnviarEmailDto dto)
        {
            try
            {
                _logger.LogInformation("Enviando factura {FacturaId} por email a {Email}", id, dto.Email);
                
                var factura = await _facturaService.ObtenerFacturaPorIdAsync(id);
                if (factura == null)
                {
                    return NotFound(new { message = "Factura no encontrada" });
                }

                var resultado = await _emailService.EnviarFacturaPorCorreoAsync(factura, dto.Email);
                
                if (resultado)
                {
                    return Ok(new { message = "Email enviado exitosamente", email = dto.Email });
                }
                else
                {
                    return StatusCode(500, new { message = "No se pudo enviar el email. Revisa los logs para más detalles." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de factura {FacturaId}", id);
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }

    /// <summary>
    /// DTO para generar una factura
    /// </summary>
    public class GenerarFacturaDto
    {
        public string SolicitudId { get; set; } = string.Empty;
        public List<DetalleFactura> Detalles { get; set; } = new List<DetalleFactura>();
        public double PorcentajeComision { get; set; } = 0.80; // 80% para empleado, 20% para dueño
    }

    /// <summary>
    /// DTO para registrar un abono
    /// </summary>
    public class AbonoDto
    {
        [System.Text.Json.Serialization.JsonRequired]
        public double Monto { get; set; }
    }

    /// <summary>
    /// DTO para enviar email de factura
    /// </summary>
    public class EnviarEmailDto
    {
        [System.Text.Json.Serialization.JsonRequired]
        public string Email { get; set; } = string.Empty;
    }
}
