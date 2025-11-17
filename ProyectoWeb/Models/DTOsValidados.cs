using System.ComponentModel.DataAnnotations;

namespace ProyectoWeb.Models
{
    /// <summary>
    /// DTO para solicitud de login con validaciones
    /// </summary>
    public class LoginRequestValidated
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre de usuario debe tener al menos 3 caracteres")]
        [MaxLength(50, ErrorMessage = "El nombre de usuario no puede exceder 50 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "El nombre de usuario solo puede contener letras, números y guiones bajos")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        [MaxLength(100, ErrorMessage = "La contraseña no puede exceder 100 caracteres")]
        public string Password { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO para registro de usuario con validaciones completas
    /// </summary>
    public class UsuarioRegistroValidado
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre de usuario debe tener al menos 3 caracteres")]
        [MaxLength(50, ErrorMessage = "El nombre de usuario no puede exceder 50 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "El nombre de usuario solo puede contener letras, números y guiones bajos")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        [MaxLength(100, ErrorMessage = "La contraseña no puede exceder 100 caracteres")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "El nombre es obligatorio")]
        [MinLength(2, ErrorMessage = "El nombre debe tener al menos 2 caracteres")]
        [MaxLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "El nombre solo puede contener letras y espacios")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El correo debe tener un formato válido")]
        [MaxLength(100, ErrorMessage = "El correo no puede exceder 100 caracteres")]
        public string Correo { get; set; } = string.Empty;

        [Required(ErrorMessage = "El teléfono es obligatorio")]
        [Phone(ErrorMessage = "El teléfono debe tener un formato válido")]
        [RegularExpression(@"^\d{8,15}$", ErrorMessage = "El teléfono debe contener entre 8 y 15 dígitos")]
        public string Telefono { get; set; } = string.Empty;

        [Required(ErrorMessage = "La dirección es obligatoria")]
        [MinLength(5, ErrorMessage = "La dirección debe tener al menos 5 caracteres")]
        [MaxLength(200, ErrorMessage = "La dirección no puede exceder 200 caracteres")]
        public string Direccion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El rol es obligatorio")]
        [RegularExpression(@"^(Cliente|Empleado|Dueno)$", ErrorMessage = "El rol debe ser: Cliente, Empleado o Dueno")]
        public string Rol { get; set; } = "Cliente";
    }

    /// <summary>
    /// DTO para producto con validaciones
    /// </summary>
    public class ProductoValidado
    {
        [Required(ErrorMessage = "El nombre del producto es obligatorio")]
        [MinLength(2, ErrorMessage = "El nombre debe tener al menos 2 caracteres")]
        [MaxLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\-\.]+$", ErrorMessage = "El nombre solo puede contener letras, números, espacios, guiones y puntos")]
        public string Nombre { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string? Descripcion { get; set; }

        [Required(ErrorMessage = "El precio es obligatorio")]
        [Range(0.01, 1000000, ErrorMessage = "El precio debe estar entre 0.01 y 1,000,000")]
        public double Precio { get; set; }

        [Required(ErrorMessage = "El stock es obligatorio")]
        [Range(0, 100000, ErrorMessage = "El stock debe estar entre 0 y 100,000")]
        public int Stock { get; set; }
    }

    /// <summary>
    /// DTO para empleado con validaciones
    /// </summary>
    public class EmpleadoValidado
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre de usuario debe tener al menos 3 caracteres")]
        [MaxLength(50, ErrorMessage = "El nombre de usuario no puede exceder 50 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "El nombre de usuario solo puede contener letras, números y guiones bajos")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        [MaxLength(100, ErrorMessage = "La contraseña no puede exceder 100 caracteres")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo electrónico es obligatorio")]
        [EmailAddress(ErrorMessage = "El correo debe tener un formato válido")]
        [MaxLength(100, ErrorMessage = "El correo no puede exceder 100 caracteres")]
        public string CorreoElectronico { get; set; } = string.Empty;

        [Required(ErrorMessage = "El nombre completo es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre completo debe tener al menos 3 caracteres")]
        [MaxLength(100, ErrorMessage = "El nombre completo no puede exceder 100 caracteres")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "El nombre completo solo puede contener letras y espacios")]
        public string NombreCompleto { get; set; } = string.Empty;

        [Required(ErrorMessage = "El porcentaje de comisión es obligatorio")]
        [Range(0, 1, ErrorMessage = "El porcentaje de comisión debe estar entre 0 y 1 (ej: 0.80 = 80%)")]
        public double PorcentajeComision { get; set; } = 0.80;
    }

    /// <summary>
    /// DTO para servicio con validaciones
    /// </summary>
    public class ServicioValidado
    {
        [Required(ErrorMessage = "El nombre del servicio es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre debe tener al menos 3 caracteres")]
        [MaxLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\-]+$", ErrorMessage = "El nombre solo puede contener letras, números, espacios y guiones")]
        public string Nombre { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string? Descripcion { get; set; }

        [Required(ErrorMessage = "El precio base es obligatorio")]
        [Range(0.01, 1000000, ErrorMessage = "El precio base debe estar entre 0.01 y 1,000,000")]
        public double PrecioBase { get; set; }
    }

    /// <summary>
    /// DTO para solicitud de servicio con validaciones
    /// </summary>
    public class SolicitudServicioValidado
    {
        [Required(ErrorMessage = "El ID del cliente es obligatorio")]
        public string ClienteId { get; set; } = string.Empty;

        [Required(ErrorMessage = "La descripción es obligatoria")]
        [MinLength(10, ErrorMessage = "La descripción debe tener al menos 10 caracteres")]
        [MaxLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string Descripcion { get; set; } = string.Empty;

        [MaxLength(1000, ErrorMessage = "El detalle no puede exceder 1000 caracteres")]
        public string? Detalle { get; set; }
    }

    /// <summary>
    /// DTO para abono con validaciones
    /// </summary>
    public class AbonoValidado
    {
        [Required(ErrorMessage = "El ID de la factura es obligatorio")]
        public string FacturaId { get; set; } = string.Empty;

        [Required(ErrorMessage = "El monto es obligatorio")]
        [Range(0.01, 1000000, ErrorMessage = "El monto debe estar entre 0.01 y 1,000,000")]
        public double Monto { get; set; }

        [Required(ErrorMessage = "El método de pago es obligatorio")]
        [RegularExpression(@"^(Efectivo|Tarjeta|Transferencia|Stripe)$", ErrorMessage = "El método de pago debe ser: Efectivo, Tarjeta, Transferencia o Stripe")]
        public string MetodoPago { get; set; } = "Efectivo";

        [MaxLength(500, ErrorMessage = "Las observaciones no pueden exceder 500 caracteres")]
        public string? Observaciones { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar usuario con validaciones
    /// </summary>
    public class UsuarioDto
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre de usuario debe tener al menos 3 caracteres")]
        [MaxLength(50, ErrorMessage = "El nombre de usuario no puede exceder 50 caracteres")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "El nombre de usuario solo puede contener letras, números y guiones bajos")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        [MaxLength(100, ErrorMessage = "La contraseña no puede exceder 100 caracteres")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo electrónico es obligatorio")]
        [EmailAddress(ErrorMessage = "El correo debe tener un formato válido")]
        [MaxLength(100, ErrorMessage = "El correo no puede exceder 100 caracteres")]
        public string CorreoElectronico { get; set; } = string.Empty;

        [Required(ErrorMessage = "El nombre completo es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre completo debe tener al menos 3 caracteres")]
        [MaxLength(100, ErrorMessage = "El nombre completo no puede exceder 100 caracteres")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "El nombre completo solo puede contener letras y espacios")]
        public string? NombreCompleto { get; set; }
    }
}
