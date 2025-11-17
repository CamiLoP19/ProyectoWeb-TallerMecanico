using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using ProyectoWeb.Models;
using ProyectoWeb.Services;
using System.Security.Claims;

namespace ProyectoWeb.Pages
{
    [IgnoreAntiforgeryToken] // Deshabilitar temporalmente para diagnosticar
    public class LoginPageModel : PageModel
    {
        private readonly AuthService _authService;
        private readonly ILogger<LoginPageModel> _logger;

        [BindProperty]
        public string NombreUsuario { get; set; } = string.Empty;

        [BindProperty]
        public string Password { get; set; } = string.Empty;

        public string? ErrorMessage { get; set; }

        public LoginPageModel(AuthService authService, ILogger<LoginPageModel> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        public void OnGet()
        {
            _logger.LogInformation("LoginPage GET - Mostrando formulario de login");
        }

        public async Task<IActionResult> OnPostAsync()
        {
            _logger.LogInformation("=== LoginPage POST RECIBIDO ===");
            _logger.LogInformation("Usuario recibido: '{Usuario}'", NombreUsuario);
            _logger.LogInformation("Password recibido: {HasPassword}", !string.IsNullOrEmpty(Password));
            
            try
            {
                // Validaciones básicas
                if (string.IsNullOrWhiteSpace(NombreUsuario))
                {
                    _logger.LogWarning("Login fallido - Usuario vacío");
                    ErrorMessage = "El nombre de usuario es requerido";
                    return Page();
                }

                if (string.IsNullOrWhiteSpace(Password))
                {
                    ErrorMessage = "La contraseña es requerida";
                    return Page();
                }

                // Validación contra XSS
                if (ContieneCaracteresInseguros(NombreUsuario))
                {
                    ErrorMessage = "El nombre de usuario contiene caracteres no permitidos";
                    _logger.LogWarning($"Intento de XSS detectado en login: {NombreUsuario}");
                    return Page();
                }

                // Autenticar usuario
                var usuario = await _authService.LoginAsync(NombreUsuario, Password);

                if (usuario == null)
                {
                    ErrorMessage = "Usuario o contraseña incorrectos";
                    _logger.LogWarning($"Intento de login fallido para usuario: {NombreUsuario}");
                    return Page();
                }

                // Crear claims del usuario
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, usuario.Id ?? string.Empty),
                    new Claim(ClaimTypes.Name, usuario.NombreUsuario),
                    new Claim(ClaimTypes.Email, usuario.CorreoElectronico),
                    new Claim(ClaimTypes.Role, usuario.RolUsuario.ToString()),
                    new Claim("RolId", usuario.Rol.ToString())
                };

                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

                // Autenticar con cookies - AQUÍ NO HAY PROBLEMA porque es Razor Pages, no Blazor
                await HttpContext.SignInAsync(
                    CookieAuthenticationDefaults.AuthenticationScheme,
                    claimsPrincipal,
                    new AuthenticationProperties
                    {
                        IsPersistent = true, // Cookie persistente
                        ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7) // 7 días
                    });

                // Redirigir según el rol
                string redirectUrl = usuario.RolUsuario switch
                {
                    RolUsuario.Administrador => "/admin",
                    RolUsuario.Empleado => "/empleado",
                    RolUsuario.Cliente => "/cliente",
                    _ => "/"
                };

                _logger.LogInformation("Cookie creada exitosamente. Redirigiendo a: {Url}", redirectUrl);

                return Redirect(redirectUrl);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error durante el login");
                ErrorMessage = "Error al iniciar sesión. Por favor, intente nuevamente.";
                return Page();
            }
        }

        private bool ContieneCaracteresInseguros(string input)
        {
            if (string.IsNullOrEmpty(input))
                return false;

            char[] caracteresInseguros = { '<', '>', '"', '\'', '/', '\\', '&', ';', '(', ')', '{', '}', '[', ']' };
            return input.IndexOfAny(caracteresInseguros) >= 0;
        }
    }
}
