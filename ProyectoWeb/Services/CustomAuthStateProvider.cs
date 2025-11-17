using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Server;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ProyectoWeb.Services
{
    /// <summary>
    /// Proveedor de estado de autenticación que usa HttpContext (cookies del servidor)
    /// </summary>
    public class CustomAuthStateProvider : RevalidatingServerAuthenticationStateProvider
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CustomAuthStateProvider(
            ILoggerFactory loggerFactory,
            IHttpContextAccessor httpContextAccessor) 
            : base(loggerFactory)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        protected override TimeSpan RevalidationInterval => TimeSpan.FromMinutes(30);

        protected override Task<bool> ValidateAuthenticationStateAsync(
            AuthenticationState authenticationState, CancellationToken cancellationToken)
        {
            // Retornar true para mantener el estado válido
            return Task.FromResult(true);
        }

        public override Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            
            if (httpContext?.User?.Identity?.IsAuthenticated == true)
            {
                return Task.FromResult(new AuthenticationState(httpContext.User));
            }

            return Task.FromResult(new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity())));
        }
    }
}



