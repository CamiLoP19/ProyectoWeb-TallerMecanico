using Google.Cloud.Firestore;
using System;
using System.Text.Json.Serialization; // Necesario para [JsonIgnore]

namespace ProyectoWeb.Models
{
    /// <summary>
    /// Enumeración para los roles de usuario
    /// </summary>
    public enum RolUsuario
    {
        Administrador = 1,
        Empleado = 2,
        Cliente = 3
    }

    /// <summary>
    /// Clase base Usuario con anotaciones para Firestore
    /// Incluye soporte para login con Google y recuperación de contraseña
    /// </summary>
    [FirestoreData]
    public class Usuario
    {
        // [FirestoreDocumentId] permite que la librería llene este campo automáticamente al leer
        [FirestoreDocumentId]
        public string? Id { get; set; }

        [FirestoreProperty]
        public string NombreUsuario { get; set; } = string.Empty;

        [FirestoreProperty]
        public string Password { get; set; } = string.Empty;

        [FirestoreProperty]
        public int Rol { get; set; } = (int)RolUsuario.Cliente;

        [FirestoreProperty]
        public string CorreoElectronico { get; set; } = string.Empty;

        [FirestoreProperty]
        public string? NombreCompleto { get; set; }

        [FirestoreProperty]
        public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

        // ============================================
        // 🆕 CAMPOS PARA LOGIN GOOGLE / AVANZADO
        // ============================================

        [FirestoreProperty]
        public string? ProveedorAutenticacion { get; set; } = "Email";

        [FirestoreProperty]
        public string? GoogleId { get; set; }

        [FirestoreProperty]
        public string? FotoUrl { get; set; }

        [FirestoreProperty]
        public bool EmailVerificado { get; set; } = false;

        [FirestoreProperty]
        public bool CuentaActiva { get; set; } = true;

        [FirestoreProperty]
        public DateTime? UltimaConexion { get; set; }

        // ============================================
        // 🆕 CAMPOS PARA SEGURIDAD Y RECUPERACIÓN
        // ============================================

        // Nota: Mantenemos "IntentosFailidos" tal cual está en tu AuthService
        [FirestoreProperty]
        public int IntentosFailidos { get; set; } = 0;

        [FirestoreProperty]
        public DateTime? BloqueadoHasta { get; set; }

        [FirestoreProperty]
        public string? TokenRecuperacion { get; set; }

        [FirestoreProperty]
        public DateTime? TokenExpiracion { get; set; }

        // ============================================
        // 🆕 PROPIEDADES CALCULADAS (Lógica de Negocio)
        // ============================================

        [JsonIgnore]
        public RolUsuario RolUsuario
        {
            get => (RolUsuario)Rol;
            set => Rol = (int)value;
        }

        // Propiedad auxiliar para verificar si usa Google
        [JsonIgnore]
        public bool UsaGoogle => ProveedorAutenticacion == "Google" || !string.IsNullOrEmpty(GoogleId);

        // Verifica si el token de recuperación es válido (existe y no ha expirado)
        [JsonIgnore]
        public bool TokenEsValido => 
            !string.IsNullOrEmpty(TokenRecuperacion) && 
            TokenExpiracion.HasValue && 
            TokenExpiracion.Value > DateTime.UtcNow;

        // Lógica para determinar si está bloqueado (por bandera manual o por tiempo de bloqueo)
        [JsonIgnore]
        public bool EstaBloqueado => 
            !CuentaActiva || 
            (BloqueadoHasta.HasValue && BloqueadoHasta.Value > DateTime.UtcNow);
    }
}