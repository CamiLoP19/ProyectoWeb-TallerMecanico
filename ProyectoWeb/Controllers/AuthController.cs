using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Models;
using ProyectoWeb.Services;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ProyectoWeb.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(AuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        /// <summary>
        /// POST: api/auth/login
        /// Autentica un usuario y crea cookie de sesión, luego redirige
        /// </summary>
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                var usuario = await _authService.LoginAsync(request.NombreUsuario, request.Password);
                
                if (usuario == null)
                {
                    _logger.LogWarning("Intento de login fallido para usuario: {Usuario}", request.NombreUsuario);
                    return Unauthorized(new { success = false, message = "Usuario o contraseña incorrectos" });
                }

                // Usar el método centralizado para crear la sesión
                string redirectUrl = await _authService.CrearSesionUsuarioAsync(HttpContext, usuario);

                return Ok(new { success = true, redirectUrl = redirectUrl });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en login");
                return StatusCode(500, new { success = false, message = "Error al procesar login" });
            }
        }

        /// <summary>
        /// POST: api/auth/registro
        /// Registra un nuevo usuario
        /// </summary>
        [HttpPost("registro")]
        public async Task<ActionResult<Usuario>> Registro([FromBody] Usuario usuario)
        {
            try
            {
                var nuevoUsuario = await _authService.RegistrarUsuarioAsync(usuario);
                return CreatedAtAction(nameof(ObtenerUsuario), new { id = nuevoUsuario.Id }, nuevoUsuario);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar usuario");
                return StatusCode(500, new { message = "Error al registrar usuario" });
            }
        }

        /// <summary>
        /// GET: api/auth/usuario/{id}
        /// Obtiene un usuario por ID
        /// </summary>
        [HttpGet("usuario/{id}")]
        public async Task<ActionResult<Usuario>> ObtenerUsuario(string id)
        {
            try
            {
                var usuario = await _authService.ObtenerUsuarioPorIdAsync(id);
                if (usuario == null)
                {
                    return NotFound(new { message = "Usuario no encontrado" });
                }
                return Ok(usuario);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener usuario {UsuarioId}", id);
                return StatusCode(500, new { message = "Error al obtener usuario" });
            }
        }

        /// <summary>
        /// POST: api/auth/logout
        /// Cierra sesión y elimina la cookie
        /// </summary>
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            try
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                _logger.LogInformation("Usuario cerró sesión");
                return Ok(new { success = true, message = "Sesión cerrada correctamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cerrar sesión");
                return StatusCode(500, new { message = "Error al cerrar sesión" });
            }
        }
    }

    /// <summary>
    /// DTO para solicitud de login
    /// </summary>
    public class LoginRequest
    {
        public string NombreUsuario { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO para respuesta de login
    /// </summary>
    public class LoginResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public Usuario? Usuario { get; set; }
        public string? RedirectUrl { get; set; }
        public string? Token { get; set; } // Para futuro JWT
    }
}
