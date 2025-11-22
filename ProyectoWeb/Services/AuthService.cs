using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using ProyectoWeb.Data;
using ProyectoWeb.Models;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace ProyectoWeb.Services
{
    public class AuthService
    {
        private readonly FirebaseService _firebaseService;
        private readonly ILogger<AuthService> _logger;
        private readonly EmailService _emailService;
        private const string COLLECTION_NAME = "usuarios";
        private const string CAMPO_NOMBRE_USUARIO = "NombreUsuario";
        private const string CAMPO_CORREO_ELECTRONICO = "CorreoElectronico";
        private const string CAMPO_TOKEN_RECUPERACION = "TokenRecuperacion";
        private const int MAX_INTENTOS_FALLIDOS = 5;
        private const int MINUTOS_BLOQUEO = 15;
        private const int HORAS_EXPIRACION_TOKEN = 1;
        private const int MIN_LONGITUD_PASSWORD = 4;

        public AuthService(FirebaseService firebaseService, ILogger<AuthService> logger, EmailService emailService)
        {
            _firebaseService = firebaseService;
            _logger = logger;
            _emailService = emailService;
        }

        // ============================================
        // LOGIN TRADICIONAL (ACTUALIZADO)
        // ============================================
        public async Task<Usuario?> LoginAsync(string nombreUsuario, string password)
        {
            try
            {
                Usuario? usuario = null;
                DocumentSnapshot? doc = null;

                var usuariosCollection = _firebaseService.GetCollection(COLLECTION_NAME);
                var queryUsuarios = usuariosCollection.WhereEqualTo(CAMPO_NOMBRE_USUARIO, nombreUsuario);
                var snapshotUsuarios = await queryUsuarios.GetSnapshotAsync();

                if (snapshotUsuarios.Count > 0)
                {
                    doc = snapshotUsuarios.Documents[0];
                    usuario = doc.ConvertTo<Usuario>();
                    usuario.Id = doc.Id;
                }
                else
                {
                    var empleadosCollection = _firebaseService.GetCollection("empleados");
                    var queryEmpleados = empleadosCollection.WhereEqualTo(CAMPO_NOMBRE_USUARIO, nombreUsuario);
                    var snapshotEmpleados = await queryEmpleados.GetSnapshotAsync();

                    if (snapshotEmpleados.Count > 0)
                    {
                        doc = snapshotEmpleados.Documents[0];
                        var empleado = doc.ConvertTo<Empleado>();
                        
                        usuario = new Usuario
                        {
                            Id = doc.Id,
                            NombreUsuario = empleado.NombreUsuario,
                            Password = empleado.Password,
                            CorreoElectronico = empleado.CorreoElectronico,
                            Rol = empleado.Rol,
                            NombreCompleto = empleado.NombreCompleto
                        };
                    }
                }

                if (usuario == null)
                {
                    _logger.LogWarning("Intento de login fallido: usuario no encontrado");
                    return null;
                }

                // 🆕 NUEVO: Verificar si la cuenta está bloqueada
                if (usuario.EstaBloqueado)
                {
                    _logger.LogWarning("Intento de login en cuenta bloqueada: {Usuario}", nombreUsuario);
                    throw new InvalidOperationException("CUENTA_BLOQUEADA");
                }

                // 🆕 NUEVO: Si el usuario se registró con Google, no puede usar login tradicional
                if (usuario.UsaGoogle)
                {
                    _logger.LogWarning("Usuario intentó login tradicional pero está registrado con Google: {Usuario}", nombreUsuario);
                    throw new InvalidOperationException("USAR_GOOGLE");
                }

                // Verificar password
                if (usuario.Password != HashPassword(password))
                {
                    _logger.LogWarning("Intento de login fallido: contraseña incorrecta");
                    
                    // 🆕 NUEVO: Incrementar intentos fallidos
                    await IncrementarIntentosFailidosAsync(doc!.Reference, usuario);
                    
                    return null;
                }

                // 🆕 NUEVO: Reset intentos fallidos y actualizar última conexión
                await ActualizarLoginExitosoAsync(doc!.Reference);

                _logger.LogInformation("Login exitoso: {NombreUsuario} - Rol: {Rol}", nombreUsuario, usuario.RolUsuario);
                return usuario;
            }
            catch (InvalidOperationException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en login");
                throw new InvalidOperationException("Error en el proceso de login", ex);
            }
        }

        // ============================================
        // 🆕 LOGIN CON GOOGLE
        // ============================================
        public async Task<Usuario> LoginConGoogleAsync(string googleId, string email, string nombreCompleto, string? fotoUrl)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);

                // Buscar usuario por GoogleId
                var queryGoogle = collection.WhereEqualTo("GoogleId", googleId);
                var snapshotGoogle = await queryGoogle.GetSnapshotAsync();

                Usuario usuario;

                if (snapshotGoogle.Count > 0)
                {
                    // Usuario existente con Google
                    var doc = snapshotGoogle.Documents[0];
                    usuario = doc.ConvertTo<Usuario>();
                    usuario.Id = doc.Id;

                    // Actualizar última conexión y foto
                    await doc.Reference.UpdateAsync(new Dictionary<string, object>
                    {
                        { "FotoUrl", fotoUrl ?? "" },
                        { "UltimaConexion", DateTime.UtcNow },
                        { "NombreCompleto", nombreCompleto }
                    });

                    _logger.LogInformation("Login con Google exitoso: {Email}", email);
                }
                else
                {
                    // Verificar si existe usuario con ese email (registrado tradicionalmente)
                    var queryEmail = collection.WhereEqualTo("CorreoElectronico", email);
                    var snapshotEmail = await queryEmail.GetSnapshotAsync();

                    if (snapshotEmail.Count > 0)
                    {
                        // Vincular cuenta existente con Google
                        var doc = snapshotEmail.Documents[0];
                        usuario = doc.ConvertTo<Usuario>();
                        usuario.Id = doc.Id;

                        await doc.Reference.UpdateAsync(new Dictionary<string, object>
                        {
                            { "GoogleId", googleId },
                            { "ProveedorAutenticacion", "Google" },
                            { "FotoUrl", fotoUrl ?? "" },
                            { "EmailVerificado", true },
                            { "UltimaConexion", DateTime.UtcNow },
                            { "NombreCompleto", nombreCompleto }
                        });

                        usuario.GoogleId = googleId;
                        usuario.ProveedorAutenticacion = "Google";
                        usuario.FotoUrl = fotoUrl;
                        usuario.EmailVerificado = true;

                        _logger.LogInformation("Cuenta vinculada con Google: {Email}", email);
                    }
                    else
                    {
                        // Crear nuevo usuario con Google
                        usuario = new Usuario
                        {
                            GoogleId = googleId,
                            CorreoElectronico = email,
                            NombreCompleto = nombreCompleto,
                            NombreUsuario = GenerarNombreUsuarioUnico(email),
                            ProveedorAutenticacion = "Google",
                            FotoUrl = fotoUrl,
                            EmailVerificado = true,
                            Rol = (int)RolUsuario.Cliente,
                            FechaCreacion = DateTime.UtcNow,
                            CuentaActiva = true
                        };

                        var docRef = await collection.AddAsync(usuario);
                        usuario.Id = docRef.Id;

                        _logger.LogInformation("Nuevo usuario creado con Google: {Email}", email);
                    }
                }

                return usuario;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en login con Google");
                throw new InvalidOperationException("Error al autenticar con Google", ex);
            }
        }

        // ============================================
        // 🆕 SOLICITAR RECUPERACIÓN DE CONTRASEÑA
        // ============================================
        public async Task<bool> SolicitarRecuperacionPasswordAsync(string email)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo(CAMPO_CORREO_ELECTRONICO, email);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot.Count == 0)
                {
                    // No revelar si el email existe o no (seguridad)
                    _logger.LogWarning("Intento de recuperación para email no registrado: {Email}", email);
                    return true; // Devolver true de todas formas
                }

                var doc = snapshot.Documents[0];
                var usuario = doc.ConvertTo<Usuario>();

                // Verificar si el usuario usa Google
                if (usuario.UsaGoogle)
                {
                    _logger.LogWarning("Usuario con Google intentó recuperar contraseña: {Email}", email);
                    throw new InvalidOperationException("USUARIO_GOOGLE");
                }

                // Generar token de recuperación
                var token = GenerarTokenRecuperacion();
                var expiracion = DateTime.UtcNow.AddHours(HORAS_EXPIRACION_TOKEN);

                await doc.Reference.UpdateAsync(new Dictionary<string, object>
                {
                    { CAMPO_TOKEN_RECUPERACION, token },
                    { "TokenExpiracion", expiracion }
                }).ConfigureAwait(false);

                // 🆕 Enviar email con el token
                try
                {
                    await _emailService.EnviarEmailRecuperacionAsync(email, token, usuario.NombreCompleto ?? usuario.NombreUsuario);
                    _logger.LogInformation("Email de recuperación enviado a {Email}", email);
                }
                catch (Exception emailEx)
                {
                    _logger.LogError(emailEx, "Error al enviar email de recuperación, pero token generado: {Token}", token);
                    // Continuar aunque falle el envío del email (el token ya está guardado)
                }
                
                _logger.LogInformation("Token de recuperación generado para {Email}: {Token}", email, token);

                return true;
            }
            catch (InvalidOperationException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al solicitar recuperación de contraseña");
                throw new InvalidOperationException("Error al procesar solicitud de recuperación", ex);
            }
        }

        // ============================================
        // 🆕 VERIFICAR TOKEN DE RECUPERACIÓN
        // ============================================
        public async Task<bool> VerificarTokenRecuperacionAsync(string token)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo(CAMPO_TOKEN_RECUPERACION, token);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot.Count == 0)
                {
                    return false;
                }

                var usuario = snapshot.Documents[0].ConvertTo<Usuario>();
                return usuario.TokenEsValido;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al verificar token");
                return false;
            }
        }

        // ============================================
        // 🆕 RESTABLECER CONTRASEÑA CON TOKEN
        // ============================================
        public async Task<bool> RestablecerPasswordAsync(string token, string nuevaPassword)
        {
            try
            {
                if (nuevaPassword.Length < MIN_LONGITUD_PASSWORD)
                {
                    throw new ArgumentException($"La contraseña debe tener al menos {MIN_LONGITUD_PASSWORD} caracteres");
                }

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo(CAMPO_TOKEN_RECUPERACION, token);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot.Count == 0)
                {
                    throw new ArgumentException("TOKEN_INVALIDO");
                }

                var doc = snapshot.Documents[0];
                var usuario = doc.ConvertTo<Usuario>();

                // Verificar si el token expiró
                if (!usuario.TokenEsValido)
                {
                    throw new ArgumentException("TOKEN_EXPIRADO");
                }

                // Actualizar password y limpiar token
                await doc.Reference.UpdateAsync(new Dictionary<string, object>
                {
                    { "Password", HashPassword(nuevaPassword) },
                    { CAMPO_TOKEN_RECUPERACION, "" },
                    { "TokenExpiracion", FieldValue.Delete },
                    { "IntentosFailidos", 0 },
                    { "BloqueadoHasta", FieldValue.Delete }
                }).ConfigureAwait(false);

                _logger.LogInformation("Contraseña restablecida exitosamente para usuario {Id}", doc.Id);
                return true;
            }
            catch (ArgumentException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al restablecer contraseña");
                throw new InvalidOperationException("Error al procesar restablecimiento de contraseña", ex);
            }
        }

        // ============================================
        // REGISTRO DE USUARIO (YA EXISTENTE)
        // ============================================
        public async Task<Usuario> RegistrarUsuarioAsync(Usuario usuario)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(usuario.NombreUsuario))
                    throw new ArgumentException("El nombre de usuario es requerido");

                if (string.IsNullOrWhiteSpace(usuario.Password))
                    throw new ArgumentException("La contraseña es requerida");

                if (string.IsNullOrWhiteSpace(usuario.CorreoElectronico))
                    throw new ArgumentException("El correo electrónico es requerido");

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var queryUsuario = collection.WhereEqualTo(CAMPO_NOMBRE_USUARIO, usuario.NombreUsuario);
                var snapshotUsuario = await queryUsuario.GetSnapshotAsync();

                if (snapshotUsuario.Count > 0)
                    throw new ArgumentException("USUARIO_EXISTE");

                var empleadosCollection = _firebaseService.GetCollection("empleados");
                var queryEmpleados = empleadosCollection.WhereEqualTo(CAMPO_NOMBRE_USUARIO, usuario.NombreUsuario);
                var snapshotEmpleados = await queryEmpleados.GetSnapshotAsync();

                if (snapshotEmpleados.Count > 0)
                    throw new ArgumentException("USUARIO_EXISTE");

                var queryCorreo = collection.WhereEqualTo(CAMPO_CORREO_ELECTRONICO, usuario.CorreoElectronico);
                var snapshotCorreo = await queryCorreo.GetSnapshotAsync();

                if (snapshotCorreo.Count > 0)
                    throw new ArgumentException("CORREO_REGISTRADO");

                var queryCorreoEmpleados = empleadosCollection.WhereEqualTo(CAMPO_CORREO_ELECTRONICO, usuario.CorreoElectronico);
                var snapshotCorreoEmpleados = await queryCorreoEmpleados.GetSnapshotAsync();

                if (snapshotCorreoEmpleados.Count > 0)
                    throw new ArgumentException("CORREO_REGISTRADO");

                usuario.Password = HashPassword(usuario.Password);
                usuario.FechaCreacion = DateTime.UtcNow;
                usuario.ProveedorAutenticacion = "Email"; // 🆕 NUEVO
                usuario.CuentaActiva = true; // 🆕 NUEVO

                var docRef = await collection.AddAsync(usuario);
                usuario.Id = docRef.Id;

                _logger.LogInformation("Usuario registrado: {NombreUsuario} - Rol: {Rol}", usuario.NombreUsuario, usuario.RolUsuario);
                return usuario;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar usuario");
                throw new InvalidOperationException("Error al registrar usuario", ex);
            }
        }

        // ============================================
        // OBTENER USUARIO POR ID
        // ============================================
        public async Task<Usuario?> ObtenerUsuarioPorIdAsync(string id)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(id);
                var snapshot = await docRef.GetSnapshotAsync();

                if (!snapshot.Exists)
                {
                    return null;
                }

                var usuario = snapshot.ConvertTo<Usuario>();
                usuario.Id = snapshot.Id;
                return usuario;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener usuario {UsuarioId}", id);
                throw new InvalidOperationException("Error al obtener usuario", ex);
            }
        }

        // ============================================
        // CREAR SESIÓN DE USUARIO
        // ============================================
        public async Task<string> CrearSesionUsuarioAsync(HttpContext httpContext, Usuario usuario)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, usuario.Id ?? string.Empty),
                new Claim(ClaimTypes.Name, usuario.NombreUsuario),
                new Claim(ClaimTypes.Email, usuario.CorreoElectronico),
                new Claim(ClaimTypes.Role, usuario.RolUsuario.ToString()),
                new Claim("RolId", usuario.Rol.ToString()),
                new Claim("ProveedorAuth", usuario.ProveedorAutenticacion ?? "Email") // 🆕 NUEVO
            };

            // 🆕 NUEVO: Agregar foto si existe
            if (!string.IsNullOrEmpty(usuario.FotoUrl))
            {
                claims.Add(new Claim("FotoUrl", usuario.FotoUrl));
            }

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            await httpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                claimsPrincipal,
                new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7)
                });

            _logger.LogInformation("Sesión creada exitosamente: {Usuario} - Rol: {Rol}", usuario.NombreUsuario, usuario.RolUsuario);

            return usuario.RolUsuario switch
            {
                RolUsuario.Administrador => "/admin",
                RolUsuario.Empleado => "/empleado",
                RolUsuario.Cliente => "/cliente",
                _ => "/"
            };
        }

        // ============================================
        // MÉTODOS AUXILIARES PRIVADOS
        // ============================================
        
        private static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        private static string GenerarTokenRecuperacion()
        {
            using (var rng = RandomNumberGenerator.Create())
            {
                byte[] tokenData = new byte[32];
                rng.GetBytes(tokenData);
                return Convert.ToBase64String(tokenData)
                    .Replace("/", "_")
                    .Replace("+", "-")
                    .Replace("=", "")
                    .Substring(0, 32);
            }
        }

        private static string GenerarNombreUsuarioUnico(string email)
        {
            var baseUsername = email.Split('@')[0];
            var random = Random.Shared.Next(1000, 9999);
            return $"{baseUsername}{random}";
        }

        private async Task IncrementarIntentosFailidosAsync(DocumentReference docRef, Usuario usuario)
        {
            var intentos = usuario.IntentosFailidos + 1;
            var updates = new Dictionary<string, object>
            {
                { "IntentosFailidos", intentos }
            };

            // Bloquear cuenta después de 5 intentos fallidos
            if (intentos >= MAX_INTENTOS_FALLIDOS)
            {
                updates["BloqueadoHasta"] = DateTime.UtcNow.AddMinutes(MINUTOS_BLOQUEO);
                updates["CuentaActiva"] = false;
                _logger.LogWarning("Cuenta bloqueada por múltiples intentos fallidos: {Usuario}", usuario.NombreUsuario);
            }

            await docRef.UpdateAsync(updates).ConfigureAwait(false);
        }

        private static async Task ActualizarLoginExitosoAsync(DocumentReference docRef)
        {
            await docRef.UpdateAsync(new Dictionary<string, object>
            {
                { "IntentosFailidos", 0 },
                { "UltimaConexion", DateTime.UtcNow },
                { "CuentaActiva", true },
                { "BloqueadoHasta", FieldValue.Delete }
            }).ConfigureAwait(false);
        }
    }
}