using Google.Cloud.Firestore;
using System;

namespace ProyectoWeb.Models
{
    /// <summary>
    /// Clase Abono con anotaciones para Firestore
    /// Representa un pago parcial o total a una factura
    /// </summary>
    [FirestoreData]
    public class Abono
    {
        [FirestoreProperty]
        public string? Id { get; set; }

        [FirestoreProperty]
        public string FacturaId { get; set; } = string.Empty;

        [FirestoreProperty]
        public string? NumeroFactura { get; set; }

        [FirestoreProperty]
        public string ClienteId { get; set; } = string.Empty;

        [FirestoreProperty]
        public string? ClienteNombre { get; set; }

        [FirestoreProperty]
        [System.Text.Json.Serialization.JsonRequired]
        public double Monto { get; set; }

        [FirestoreProperty]
        public string? MetodoPago { get; set; } // Efectivo, Tarjeta, Transferencia, etc.

        [FirestoreProperty]
        public string? Observaciones { get; set; }

        [FirestoreProperty]
        public DateTime FechaAbono { get; set; } = DateTime.UtcNow;
    }
}
