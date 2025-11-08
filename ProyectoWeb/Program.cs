using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using ProyectoWeb.Data;
using ProyectoWeb.Services;

var builder = WebApplication.CreateBuilder(args);

// Configurar servicios
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Configurar Controllers para API REST
builder.Services.AddControllers()
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

// Configurar Autenticación y Autorización
builder.Services.AddScoped<CustomAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(provider => 
    provider.GetRequiredService<CustomAuthStateProvider>());
builder.Services.AddAuthorizationCore();

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

// Configurar CORS si es necesario
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

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

app.UseCors();

app.MapBlazorHub();
app.MapControllers(); // Habilitar endpoints de API
app.MapFallbackToPage("/_Host");

await app.RunAsync();
