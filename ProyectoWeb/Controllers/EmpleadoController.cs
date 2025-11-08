using Microsoft.AspNetCore.Mvc;
using ProyectoWeb.Models;
using ProyectoWeb.Services;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ProyectoWeb.Controllers
{
    /// <summary>
    /// Controlador API REST para gestión de Empleados
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class EmpleadoController : ControllerBase
    {
        private readonly EmpleadoService _empleadoService;
        private readonly ILogger<EmpleadoController> _logger;

        public EmpleadoController(EmpleadoService empleadoService, ILogger<EmpleadoController> logger)
        {
            _empleadoService = empleadoService;
            _logger = logger;
        }

        /// <summary>
        /// Obtiene todos los empleados activos
        /// GET: api/empleado
        /// </summary>
        /// <returns>Lista de empleados</returns>
        [HttpGet]
        [ProducesResponseType(typeof(List<Empleado>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<List<Empleado>>> GetEmpleados()
        {
            try
            {
                _logger.LogInformation("Obteniendo lista de empleados");
                var empleados = await _empleadoService.ObtenerEmpleadosAsync();
                return Ok(empleados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener empleados");
                return StatusCode(StatusCodes.Status500InternalServerError, 
                    new { message = "Error al obtener empleados", error = ex.Message });
            }
        }

        /// <summary>
        /// Obtiene un empleado específico por ID
        /// GET: api/empleado/{id}
        /// </summary>
        /// <param name="id">ID del empleado</param>
        /// <returns>Empleado encontrado</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(Empleado), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<Empleado>> GetEmpleado(string id)
        {
            try
            {
                _logger.LogInformation($"Obteniendo empleado con ID: {id}");
                var empleado = await _empleadoService.ObtenerEmpleadoPorIdAsync(id);

                if (empleado == null)
                {
                    _logger.LogWarning($"Empleado con ID {id} no encontrado");
                    return NotFound(new { message = $"Empleado con ID {id} no encontrado" });
                }

                return Ok(empleado);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al obtener empleado con ID: {id}");
                return StatusCode(StatusCodes.Status500InternalServerError, 
                    new { message = "Error al obtener empleado", error = ex.Message });
            }
        }

        /// <summary>
        /// Crea un nuevo empleado
        /// POST: api/empleado
        /// </summary>
        /// <param name="empleado">Datos del empleado a crear</param>
        /// <returns>Empleado creado</returns>
        [HttpPost]
        [ProducesResponseType(typeof(Empleado), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<Empleado>> PostEmpleado([FromBody] Empleado empleado)
        {
            try
            {
                _logger.LogInformation("Creando nuevo empleado");

                if (empleado == null)
                {
                    return BadRequest(new { message = "Los datos del empleado son requeridos" });
                }

                var resultado = await _empleadoService.RegistrarEmpleadoAsync(empleado);

                if (!resultado.Success)
                {
                    _logger.LogWarning($"Error de validación al crear empleado: {resultado.Message}");
                    return BadRequest(new { message = resultado.Message });
                }

                empleado.Id = resultado.Id;
                _logger.LogInformation($"Empleado creado exitosamente con ID: {resultado.Id}");

                return CreatedAtAction(nameof(GetEmpleado), new { id = resultado.Id }, empleado);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear empleado");
                return StatusCode(StatusCodes.Status500InternalServerError, 
                    new { message = "Error al crear empleado", error = ex.Message });
            }
        }

        /// <summary>
        /// Actualiza un empleado existente
        /// PUT: api/empleado/{id}
        /// </summary>
        /// <param name="id">ID del empleado a actualizar</param>
        /// <param name="empleado">Datos actualizados del empleado</param>
        /// <returns>Resultado de la operación</returns>
        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult> PutEmpleado(string id, [FromBody] Empleado empleado)
        {
            try
            {
                _logger.LogInformation($"Actualizando empleado con ID: {id}");

                if (empleado == null)
                {
                    return BadRequest(new { message = "Los datos del empleado son requeridos" });
                }

                if (string.IsNullOrWhiteSpace(id) || id != empleado.Id)
                {
                    return BadRequest(new { message = "El ID del empleado no coincide" });
                }

                var resultado = await _empleadoService.ActualizarEmpleadoAsync(empleado);

                if (!resultado.Success)
                {
                    _logger.LogWarning($"Error al actualizar empleado: {resultado.Message}");
                    
                    if (resultado.Message.Contains("no existe"))
                        return NotFound(new { message = resultado.Message });
                    
                    return BadRequest(new { message = resultado.Message });
                }

                _logger.LogInformation($"Empleado con ID {id} actualizado exitosamente");
                return Ok(new { message = resultado.Message, empleado });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al actualizar empleado con ID: {id}");
                return StatusCode(StatusCodes.Status500InternalServerError, 
                    new { message = "Error al actualizar empleado", error = ex.Message });
            }
        }

        /// <summary>
        /// Elimina (marca como inactivo) un empleado
        /// DELETE: api/empleado/{id}
        /// </summary>
        /// <param name="id">ID del empleado a eliminar</param>
        /// <returns>Resultado de la operación</returns>
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult> DeleteEmpleado(string id)
        {
            try
            {
                _logger.LogInformation($"Eliminando empleado con ID: {id}");

                var resultado = await _empleadoService.EliminarEmpleadoAsync(id);

                if (!resultado.Success)
                {
                    _logger.LogWarning($"Error al eliminar empleado: {resultado.Message}");
                    
                    if (resultado.Message.Contains("no existe"))
                        return NotFound(new { message = resultado.Message });
                    
                    return BadRequest(new { message = resultado.Message });
                }

                _logger.LogInformation($"Empleado con ID {id} eliminado exitosamente");
                return Ok(new { message = resultado.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al eliminar empleado con ID: {id}");
                return StatusCode(StatusCodes.Status500InternalServerError, 
                    new { message = "Error al eliminar empleado", error = ex.Message });
            }
        }
    }
}
