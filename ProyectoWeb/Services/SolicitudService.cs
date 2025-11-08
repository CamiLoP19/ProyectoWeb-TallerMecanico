using Google.Cloud.Firestore;
using Microsoft.Extensions.Logging;
using ProyectoWeb.Data;
using ProyectoWeb.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ProyectoWeb.Services
{
    public class SolicitudService
    {
        private readonly FirebaseService _firebaseService;
        private readonly ILogger<SolicitudService> _logger;
        private const string COLLECTION_NAME = "solicitudes";
        private const string FIELD_ESTADO = "Estado";

        public SolicitudService(FirebaseService firebaseService, ILogger<SolicitudService> logger)
        {
            _firebaseService = firebaseService;
            _logger = logger;
        }

        /// <summary>
        /// Obtiene todas las solicitudes
        /// </summary>
        public async Task<List<SolicitudServicio>> ObtenerSolicitudesAsync()
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var snapshot = await collection.GetSnapshotAsync();

                return snapshot.Documents
                    .Select(doc =>
                    {
                        var solicitud = doc.ConvertTo<SolicitudServicio>();
                        solicitud.Id = doc.Id;
                        return solicitud;
                    })
                    .OrderByDescending(s => s.FechaSolicitud)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener solicitudes");
                throw new InvalidOperationException("Error al obtener solicitudes", ex);
            }
        }

        /// <summary>
        /// Obtiene solicitudes pendientes (no asignadas)
        /// </summary>
        public async Task<List<SolicitudServicio>> ObtenerSolicitudesPendientesAsync()
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo(FIELD_ESTADO, (int)EstadoSolicitud.Pendiente);
                var snapshot = await query.GetSnapshotAsync();

                return snapshot.Documents
                    .Select(doc =>
                    {
                        var solicitud = doc.ConvertTo<SolicitudServicio>();
                        solicitud.Id = doc.Id;
                        return solicitud;
                    })
                    .OrderBy(s => s.FechaSolicitud)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener solicitudes pendientes");
                throw new InvalidOperationException("Error al obtener solicitudes pendientes", ex);
            }
        }

        /// <summary>
        /// Obtiene solicitudes de un cliente específico
        /// </summary>
        public async Task<List<SolicitudServicio>> ObtenerSolicitudesPorClienteAsync(string clienteId)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo("ClienteId", clienteId);
                var snapshot = await query.GetSnapshotAsync();

                return snapshot.Documents
                    .Select(doc =>
                    {
                        var solicitud = doc.ConvertTo<SolicitudServicio>();
                        solicitud.Id = doc.Id;
                        return solicitud;
                    })
                    .OrderByDescending(s => s.FechaSolicitud)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener solicitudes del cliente {ClienteId}", clienteId);
                throw new InvalidOperationException("Error al obtener solicitudes del cliente", ex);
            }
        }

        /// <summary>
        /// Obtiene solicitudes asignadas a un empleado específico
        /// </summary>
        public async Task<List<SolicitudServicio>> ObtenerSolicitudesPorEmpleadoAsync(string empleadoId)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo("EmpleadoId", empleadoId);
                var snapshot = await query.GetSnapshotAsync();

                return snapshot.Documents
                    .Select(doc =>
                    {
                        var solicitud = doc.ConvertTo<SolicitudServicio>();
                        solicitud.Id = doc.Id;
                        return solicitud;
                    })
                    .OrderByDescending(s => s.FechaSolicitud)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener solicitudes del empleado {EmpleadoId}", empleadoId);
                throw new InvalidOperationException("Error al obtener solicitudes del empleado", ex);
            }
        }

        /// <summary>
        /// Obtiene una solicitud por ID
        /// </summary>
        public async Task<SolicitudServicio?> ObtenerSolicitudPorIdAsync(string id)
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

                var solicitud = snapshot.ConvertTo<SolicitudServicio>();
                solicitud.Id = snapshot.Id;
                return solicitud;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener solicitud {SolicitudId}", id);
                throw new InvalidOperationException("Error al obtener solicitud", ex);
            }
        }

        /// <summary>
        /// Crea una nueva solicitud de servicio (Cliente)
        /// </summary>
        public async Task<SolicitudServicio> CrearSolicitudAsync(SolicitudServicio solicitud)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(solicitud.ClienteId))
                    throw new ArgumentException("El ID del cliente es requerido");

                if (string.IsNullOrWhiteSpace(solicitud.Descripcion))
                    throw new ArgumentException("La descripción es requerida");

                // ServicioId es opcional - el empleado lo asignará al tomar la solicitud
                solicitud.Estado = (int)EstadoSolicitud.Pendiente;
                solicitud.FechaSolicitud = DateTime.UtcNow;
                solicitud.EmpleadoId = null;
                solicitud.FechaAsignacion = null;
                solicitud.FechaCompletada = null;

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = await collection.AddAsync(solicitud);
                solicitud.Id = docRef.Id;

                _logger.LogInformation("Solicitud creada: {SolicitudId}", solicitud.Id);
                return solicitud;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear solicitud");
                throw new InvalidOperationException("Error al crear solicitud", ex);
            }
        }

        /// <summary>
        /// Asigna una solicitud a un empleado (Empleado toma el servicio)
        /// </summary>
        public async Task AsignarSolicitudAsync(string solicitudId, string empleadoId, string empleadoNombre)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(solicitudId);
                
                // Verificar que la solicitud esté pendiente
                var snapshot = await docRef.GetSnapshotAsync();
                if (!snapshot.Exists)
                    throw new InvalidOperationException("Solicitud no encontrada");

                var solicitud = snapshot.ConvertTo<SolicitudServicio>();
                if (solicitud.EstadoSolicitud != EstadoSolicitud.Pendiente)
                    throw new InvalidOperationException("La solicitud ya no está disponible");

                await docRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "EmpleadoId", empleadoId },
                    { "EmpleadoNombre", empleadoNombre },
                    { FIELD_ESTADO, (int)EstadoSolicitud.EnProceso },
                    { "FechaAsignacion", DateTime.UtcNow }
                });

                _logger.LogInformation("Solicitud {SolicitudId} asignada al empleado {EmpleadoId}", solicitudId, empleadoId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar solicitud {SolicitudId}", solicitudId);
                throw new InvalidOperationException("Error al asignar solicitud", ex);
            }
        }

        /// <summary>
        /// Marca una solicitud como completada (cuando se genera la factura)
        /// </summary>
        public async Task CompletarSolicitudAsync(string solicitudId)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(solicitudId);
                
                await docRef.UpdateAsync(new Dictionary<string, object>
                {
                    { FIELD_ESTADO, (int)EstadoSolicitud.Completada },
                    { "FechaCompletada", DateTime.UtcNow }
                });

                _logger.LogInformation("Solicitud {SolicitudId} completada", solicitudId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al completar solicitud {SolicitudId}", solicitudId);
                throw new InvalidOperationException("Error al completar solicitud", ex);
            }
        }

        /// <summary>
        /// Cancela una solicitud
        /// </summary>
        public async Task CancelarSolicitudAsync(string solicitudId)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(solicitudId);
                
                await docRef.UpdateAsync(FIELD_ESTADO, (int)EstadoSolicitud.Cancelada);

                _logger.LogInformation("Solicitud {SolicitudId} cancelada", solicitudId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cancelar solicitud {SolicitudId}", solicitudId);
                throw new InvalidOperationException("Error al cancelar solicitud", ex);
            }
        }
    }
}
