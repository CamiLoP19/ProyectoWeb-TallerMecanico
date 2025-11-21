using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Data;
using ProyectoWeb.Services;
using Microsoft.AspNetCore.DataProtection;

var builder = WebApplication.CreateBuilder(args);

// Cargar configuración de appsettings.Local.json si existe
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true);

// Configurar servicios
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Configurar Controllers para API REST con validaciones automáticas
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        // Habilitar respuestas automáticas de validación
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value.Errors.Count > 0)
                .Select(e => new 
                {
                    Campo = e.Key,
                    Errores = e.Value.Errors.Select(x => x.ErrorMessage).ToArray()
                }).ToList();

            return new BadRequestObjectResult(new
            {
                message = "Errores de validación",
                errors = errors
            });
        };
    })
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Mantener nombres de propiedades
        options.JsonSerializerOptions.WriteIndented = true; // JSON legible
    });

// Registrar FirebaseService como Singleton
builder.Services.AddSingleton(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    return FirebaseService.GetInstance(configuration);
});

// Registrar todos los servicios de negocio como Scoped
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<EmpleadoService>();
builder.Services.AddScoped<ProductoService>();
builder.Services.AddScoped<ServicioService>();
builder.Services.AddScoped<SolicitudService>();
builder.Services.AddScoped<FacturaService>();
builder.Services.AddScoped<AbonoService>();
builder.Services.AddScoped<EmailService>();
builder.Services.AddScoped<CodigoBarrasService>();
builder.Services.AddScoped<GananciaService>();
builder.Services.AddScoped<StripePaymentService>();
builder.Services.AddScoped<DataSeeder>();

// Configurar Autenticación con Cookies
builder.Services.AddAuthentication("Cookies")
    .AddCookie("Cookies", options =>
    {
        options.LoginPath = "/loginpage"; // Cambiar a Razor Page
        options.LogoutPath = "/logout";
        options.ExpireTimeSpan = TimeSpan.FromDays(7); // Sesión de 7 días
        options.SlidingExpiration = true; // Renovar cookie automáticamente
        options.Cookie.Name = "TallerMecanicoAuth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Lax;
    });

builder.Services.AddAuthorizationCore();
builder.Services.AddHttpContextAccessor();

// Configurar AuthStateProvider personalizado
builder.Services.AddScoped<CustomAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(provider => 
    provider.GetRequiredService<CustomAuthStateProvider>());

// Agregar servicios para estado de autenticación en cascada
builder.Services.AddCascadingAuthenticationState();

// Configurar HttpClient para Blazor
builder.Services.AddScoped(sp => new HttpClient
{
    BaseAddress = new Uri(sp.GetRequiredService<NavigationManager>().BaseUri)
});

// Agregar servicios de logging
builder.Services.AddLogging(logging =>
{
    logging.AddConsole();
    logging.AddDebug();
});
// Esto guarda las llaves de sesión en un archivo para que no se borren al reiniciar
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "keys")));

var app = builder.Build();

// Inicializar datos por defecto (crear admin)
using (var scope = app.Services.CreateScope())
{
    var seeder = scope.ServiceProvider.GetRequiredService<DataSeeder>();
    await seeder.SeedAdminUserAsync();
}

// Configurar el pipeline de solicitudes HTTP
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}
else
{
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

// IMPORTANTE: Agregar middlewares de autenticación
app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages(); // Habilitar Razor Pages para login/logout
app.MapBlazorHub();
app.MapControllers(); // Habilitar endpoints de API
app.MapFallbackToPage("/_Host");

await app.RunAsync();
