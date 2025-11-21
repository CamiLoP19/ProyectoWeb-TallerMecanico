using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Data;
using ProyectoWeb.Services;
using Microsoft.AspNetCore.DataProtection;

var builder = WebApplication.CreateBuilder(args);

// ========== CONFIGURAR FIREBASE PRIMERO ==========
Console.WriteLine("========================================");
Console.WriteLine("CONFIGURANDO FIREBASE");
Console.WriteLine("========================================");

var credentialsPath = Path.Combine(Directory.GetCurrentDirectory(), "firebase-credentials.json");
Console.WriteLine($"Ruta completa: {credentialsPath}");
Console.WriteLine($"¿Archivo existe? {File.Exists(credentialsPath)}");

if (!File.Exists(credentialsPath))
{
    Console.WriteLine($"ERROR: No se encontró el archivo");
    throw new FileNotFoundException($"No se encontró: {credentialsPath}");
}

Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);
Console.WriteLine("✓ Variable GOOGLE_APPLICATION_CREDENTIALS configurada");
Console.WriteLine("========================================");
// ==================================================

// Cargar configuración de appsettings.Local.json si existe
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true);

// Configurar servicios
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Configurar Controllers para API REST
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
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
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
        options.JsonSerializerOptions.WriteIndented = true;
    });

// Registrar FirebaseService
builder.Services.AddSingleton(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    return FirebaseService.GetInstance(configuration);
});

// Registrar servicios
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

// Configurar Autenticación
builder.Services.AddAuthentication("Cookies")
    .AddCookie("Cookies", options =>
    {
        options.LoginPath = "/loginpage";
        options.LogoutPath = "/logout";
        options.ExpireTimeSpan = TimeSpan.FromDays(7);
        options.SlidingExpiration = true;
        options.Cookie.Name = "TallerMecanicoAuth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Lax;
    });

builder.Services.AddAuthorizationCore();
builder.Services.AddHttpContextAccessor();

builder.Services.AddScoped<CustomAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(provider => 
    provider.GetRequiredService<CustomAuthStateProvider>());

builder.Services.AddCascadingAuthenticationState();

builder.Services.AddScoped(sp => new HttpClient
{
    BaseAddress = new Uri(sp.GetRequiredService<NavigationManager>().BaseUri)
});

builder.Services.AddLogging(logging =>
{
    logging.AddConsole();
    logging.AddDebug();
});

builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "keys")));

var app = builder.Build();

// Inicializar datos
using (var scope = app.Services.CreateScope())
{
    var seeder = scope.ServiceProvider.GetRequiredService<DataSeeder>();
    await seeder.SeedAdminUserAsync();
}

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
app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages();
app.MapBlazorHub();
app.MapControllers();
app.MapFallbackToPage("/_Host");

await app.RunAsync();