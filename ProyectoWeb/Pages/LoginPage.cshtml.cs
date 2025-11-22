using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using ProyectoWeb.Models;
using ProyectoWeb.Services;
using System.Security.Claims;

namespace ProyectoWeb.Pages
{
    [IgnoreAntiforgeryToken]
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

        // ============================================
        // 🆕 HANDLER PARA LOGIN CON GOOGLE
        // ============================================
        public IActionResult OnPostGoogle()
        {
            _logger.LogInformation("Iniciando autenticación con Google");
            
            // Redirigir a Google OAuth
            var properties = new AuthenticationProperties
            {
                RedirectUri = Url.Page("/LoginPage", "GoogleCallback")
            };

            return Challenge(properties, "Google");
        }

        // ============================================
        // 🆕 CALLBACK DE GOOGLE OAUTH
        // ============================================
        public async Task<IActionResult> OnGetGoogleCallbackAsync()
        {
            try
            {
                _logger.LogInformation("Callback de Google recibido");

                // Obtener información del usuario autenticado por Google
                var authenticateResult = await HttpContext.AuthenticateAsync("Google");

                if (!authenticateResult.Succeeded)
                {
                    ErrorMessage = "No se pudo autenticar con Google. Intenta nuevamente.";
                    _logger.LogWarning("Autenticación con Google falló");
                    return Page();
                }

                var claims = authenticateResult.Principal.Claims;
                var googleId = claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                var email = claims.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
                var nombreCompleto = claims.FirstOrDefault(c => c.Type == ClaimTypes.Name)?.Value;
                var fotoUrl = claims.FirstOrDefault(c => c.Type == "picture")?.Value;

                if (string.IsNullOrEmpty(googleId) || string.IsNullOrEmpty(email))
                {
                    ErrorMessage = "No se pudo obtener la información de Google.";
                    _logger.LogError("Google no proporcionó ID o email");
                    return Page();
                }

                // Autenticar o crear usuario con Google
                var usuario = await _authService.LoginConGoogleAsync(
                    googleId, 
                    email, 
                    nombreCompleto ?? email, 
                    fotoUrl
                );

                // Crear sesión
                string redirectUrl = await _authService.CrearSesionUsuarioAsync(HttpContext, usuario);

                _logger.LogInformation("Login con Google exitoso: {Email}", email);
                return Redirect(redirectUrl);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en callback de Google");
                ErrorMessage = "Error al procesar login con Google. Intenta nuevamente.";
                return RedirectToPage("/LoginPage");
            }
        }

        // ============================================
        // LOGIN TRADICIONAL (ACTUALIZADO)
        // ============================================
        public async Task<IActionResult> OnPostAsync()
        {
            _logger.LogInformation("LoginPage POST - Usuario: {Usuario}, HasPassword: {HasPassword}", 
                NombreUsuario ?? "vacío", !string.IsNullOrEmpty(Password));
            
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
                    _logger.LogWarning("Intento de XSS detectado en login: {Usuario}", NombreUsuario);
                    return Page();
                }

                // Autenticar usuario
                var usuario = await _authService.LoginAsync(NombreUsuario, Password);

                if (usuario == null)
                {
                    ErrorMessage = "Usuario o contraseña incorrectos";
                    _logger.LogWarning("Intento de login fallido para usuario: {Usuario}", NombreUsuario);
                    return Page();
                }

                // Usar el método centralizado para crear la sesión
                string redirectUrl = await _authService.CrearSesionUsuarioAsync(HttpContext, usuario);

                _logger.LogInformation("Cookie creada exitosamente. Redirigiendo a: {Url}", redirectUrl);

                return Redirect(redirectUrl);
            }
            catch (InvalidOperationException ex) when (ex.Message == "USAR_GOOGLE")
            {
                // 🆕 Usuario registrado con Google intenta login tradicional
                ErrorMessage = "Esta cuenta está vinculada con Google. Por favor, usa el botón 'Continuar con Google'.";
                _logger.LogWarning("Usuario con Google intentó login tradicional: {Usuario}", NombreUsuario);
                return Page();
            }
            catch (InvalidOperationException ex) when (ex.Message == "CUENTA_BLOQUEADA")
            {
                // 🆕 Cuenta bloqueada por múltiples intentos fallidos
                ErrorMessage = "Tu cuenta ha sido bloqueada temporalmente por seguridad. Intenta nuevamente en 15 minutos o recupera tu contraseña.";
                _logger.LogWarning("Intento de login en cuenta bloqueada: {Usuario}", NombreUsuario);
                return Page();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error durante el login");
                ErrorMessage = "Error al iniciar sesión. Por favor, intente nuevamente.";
                return Page();
            }
        }

        private static bool ContieneCaracteresInseguros(string input)
        {
            if (string.IsNullOrEmpty(input))
                return false;

            char[] caracteresInseguros = { '<', '>', '"', '\'', '/', '\\', '&', ';', '(', ')', '{', '}', '[', ']' };
            return input.IndexOfAny(caracteresInseguros) >= 0;
        }
    }
}