using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace ProyectoWeb.Pages
{
    public class LogoutPageModel : PageModel
    {
        private readonly ILogger<LogoutPageModel> _logger;

        public LogoutPageModel(ILogger<LogoutPageModel> logger)
        {
            _logger = logger;
        }

        public async Task<IActionResult> OnGetAsync()
        {
            try
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                _logger.LogInformation("Usuario cerró sesión");
                return Redirect("/loginpage");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cerrar sesión");
                return Redirect("/loginpage");
            }
        }
    }
}
