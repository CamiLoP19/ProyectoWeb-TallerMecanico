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
    public class ProductoService
    {
        private readonly FirebaseService _firebaseService;
        private readonly ILogger<ProductoService> _logger;
        private const string COLLECTION_NAME = "productos";

        public ProductoService(FirebaseService firebaseService, ILogger<ProductoService> logger)
        {
            _firebaseService = firebaseService;
            _logger = logger;
        }

        /// <summary>
        /// Obtiene todos los productos activos
        /// </summary>
        public async Task<List<Producto>> ObtenerProductosAsync()
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var query = collection.WhereEqualTo("Activo", true);
                var snapshot = await query.GetSnapshotAsync();

                return snapshot.Documents
                    .Select(doc =>
                    {
                        var producto = doc.ConvertTo<Producto>();
                        producto.Id = doc.Id;
                        return producto;
                    })
                    .OrderBy(p => p.Nombre)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener productos");
                throw new InvalidOperationException("Error al obtener productos", ex);
            }
        }

        /// <summary>
        /// Obtiene un producto por ID
        /// </summary>
        public async Task<Producto?> ObtenerProductoPorIdAsync(string id)
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

                var producto = snapshot.ConvertTo<Producto>();
                producto.Id = snapshot.Id;
                return producto;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener producto {ProductoId}", id);
                throw new InvalidOperationException("Error al obtener producto", ex);
            }
        }

        /// <summary>
        /// Registra un nuevo producto
        /// </summary>
        public async Task<Producto> RegistrarProductoAsync(Producto producto)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(producto.Nombre))
                    throw new ArgumentException("El nombre del producto es requerido");

                if (producto.Precio <= 0)
                    throw new ArgumentException("El precio debe ser mayor a cero");

                if (producto.Stock < 0)
                    throw new ArgumentException("El stock no puede ser negativo");

                producto.FechaCreacion = DateTime.UtcNow;
                producto.Activo = true;

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = await collection.AddAsync(producto);
                producto.Id = docRef.Id;

                _logger.LogInformation("Producto registrado: {ProductoNombre}", producto.Nombre);
                return producto;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar producto");
                throw new InvalidOperationException("Error al registrar producto", ex);
            }
        }

        /// <summary>
        /// Actualiza un producto existente
        /// </summary>
        public async Task<Producto> ActualizarProductoAsync(Producto producto)
        {
            try
            {
                if (string.IsNullOrEmpty(producto.Id))
                    throw new ArgumentException("El ID del producto es requerido");

                // Validaciones
                if (string.IsNullOrWhiteSpace(producto.Nombre))
                    throw new ArgumentException("El nombre del producto es requerido");

                if (producto.Precio <= 0)
                    throw new ArgumentException("El precio debe ser mayor a cero");

                if (producto.Stock < 0)
                    throw new ArgumentException("El stock no puede ser negativo");

                producto.FechaModificacion = DateTime.UtcNow;

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(producto.Id);
                await docRef.SetAsync(producto, SetOptions.MergeAll);

                _logger.LogInformation("Producto actualizado: {ProductoNombre}", producto.Nombre);
                return producto;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar producto {ProductoId}", producto.Id);
                throw new InvalidOperationException("Error al actualizar producto", ex);
            }
        }

        /// <summary>
        /// Elimina un producto (soft delete)
        /// </summary>
        public async Task EliminarProductoAsync(string id)
        {
            try
            {
                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(id);
                
                await docRef.UpdateAsync("Activo", false);
                await docRef.UpdateAsync("FechaModificacion", DateTime.UtcNow);

                _logger.LogInformation("Producto eliminado: {ProductoId}", id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar producto {ProductoId}", id);
                throw new InvalidOperationException("Error al eliminar producto", ex);
            }
        }

        /// <summary>
        /// Actualiza el stock de un producto
        /// </summary>
        public async Task ActualizarStockAsync(string id, int nuevoStock)
        {
            try
            {
                if (nuevoStock < 0)
                    throw new ArgumentException("El stock no puede ser negativo");

                var collection = _firebaseService.GetCollection(COLLECTION_NAME);
                var docRef = collection.Document(id);
                
                await docRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "Stock", nuevoStock },
                    { "FechaModificacion", DateTime.UtcNow }
                });

                _logger.LogInformation("Stock actualizado para producto {ProductoId}: {NuevoStock}", id, nuevoStock);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar stock del producto {ProductoId}", id);
                throw new InvalidOperationException("Error al actualizar stock", ex);
            }
        }

        /// <summary>
        /// Reduce el stock de un producto (para ventas)
        /// </summary>
        public async Task ReducirStockAsync(string id, int cantidad)
        {
            try
            {
                var producto = await ObtenerProductoPorIdAsync(id);
                if (producto == null)
                    throw new InvalidOperationException("Producto no encontrado");

                if (producto.Stock < cantidad)
                    throw new InvalidOperationException("Stock insuficiente");

                await ActualizarStockAsync(id, producto.Stock - cantidad);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al reducir stock del producto {ProductoId}", id);
                throw;
            }
        }
    }
}
