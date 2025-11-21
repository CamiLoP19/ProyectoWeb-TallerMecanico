
Código	Nombre del Requisito	Descripción Resumida
RF-01	Registro de Clientes	Permite el registro de nuevos clientes en el sistema.
RF-02	Inicio de Sesión	Autentica usuarios mediante nombre de usuario y contraseña.
RF-03	Crear Empleado	El administrador puede registrar nuevos empleados.
RF-04	Listar Empleados	Muestra la lista de empleados activos o todos.
RF-05	Actualizar Empleado	Modifica datos personales, correo o comisión.
RF-06	Eliminar Empleado	Desactiva a los empleados
RF-07	Crear Producto	Permite registrar productos en el inventario.
RF-08	Listar Productos	Muestra todos los productos o solo los activos.
RF-09	Actualizar Producto	Modifica información de productos existentes.
RF- 10	Eliminar Producto	Desactiva productos del catálogo.
RF-11	Crear Servicio	Permite registrar servicios ofrecidos por el taller.
RF- 12	Listar Servicios	Muestra catálogo de servicios activos.
RF- 13	Actualizar Servicio	Modifica datos de servicios existentes.
RF- 14	Crear Solicitud	Clientes pueden crear solicitudes de servicio.
RF-15	Listar Solicitudes por Cliente	Muestra las solicitudes de un cliente autenticado.
RF-16	Listar Solicitudes por Empleado	Muestra solicitudes asignadas a un empleado.
RF-17	Actualizar Estado de Solicitud	Cambia estado de solicitud (pendiente, proceso, completada, cancelada).
RF- 18	Consultar Solicitud	Permite ver el detalle de una solicitud.
RF- 19	Crear Factura	Genera facturas con productos y servicios.
RF-20	Generar Factura desde Solicitud	Crea factura vinculada a una solicitud completada.
RF-21	Listar Facturas	Muestra todas las facturas registradas.
RF-22	Listar Facturas por Cliente	Permite al cliente consultar sus facturas.
RF-23	Actualizar Estado de Pago	Permite marcar facturas como pagadas o pendientes.
RF-24	Reenviar Factura por Email	Envía factura al correo del cliente.
RF-25	Crear Abono	Permite registrar pagos parciales o totales.
RF-26	Listar Abonos	Muestra todos los abonos realizados.
RF-27	Ver Ganancias del taller y exportar a pdf	Muestra con información detallada las ganancias del taller por mes 


no funcionales:

Código	Categoría	Descripción Resumida
RNF-01.1	Rendimiento	Operaciones CRUD deben ejecutarse en menos de 2 segundos.
RNF-01.2	Rendimiento	Soporta mínimo 50 usuarios concurrentes.
RNF-01.3	Rendimiento	Consultas optimizadas para reducir llamadas a la base de datos.
RNF-02.1	Escalabilidad	Firestore permite crecimiento sin pérdida de rendimiento.
RNF-02.2	Escalabilidad	Aplicación escalable horizontalmente.
RNF-02.3	Escalabilidad	Código modular y desacoplado por capas.
RNF-03.1	Seguridad	Toda comunicación se realiza mediante HTTPS y HSTS.
RNF-03.2	Seguridad	Control de acceso basado en roles.
RNF-03.3	Seguridad	Validación de datos en cliente y servidor.
RNF-03.4	Seguridad	Credenciales y llaves API protegidas fuera del código fuente.
RNF-03.5	Seguridad	(Pendiente) Implementar hash seguro para contraseñas.
RNF-04.1	Disponibilidad	Uptime mínimo del sistema: 99.5%.
RNF-04.2	Disponibilidad	Recuperación ante fallos sin pérdida de datos.
RNF-05.1	Mantenibilidad	Código limpio, comentado y organizado en capas.
RNF-05.2	Mantenibilidad	Logging estructurado con niveles de severidad.
RNF-05.3	Mantenibilidad	Configuración separada del código (appsettings.json).
RNF-06.1	Usabilidad	Interfaz intuitiva y responsiva con Bootstrap.
RNF-06.2	Usabilidad	Mensajes de retroalimentación claros al usuario.
RNF-06.3	Usabilidad	Compatible con PC, tablet y dispositivos móviles.
RNF-07.1	Portabilidad	Multiplataforma (.NET 8: Windows, Linux, macOS).
RNF-07.2	Portabilidad	Compatible con navegadores modernos (Chrome, Edge, Firefox, Safari).
RNF-08.1	Integrabilidad	API RESTful estándar con respuestas JSON.
RNF-08.2	Integrabilidad	Integración con Stripe, Gmail/SMTP, Firebase, ZXing.
RNF-08.3	Integrabilidad	Webhooks para notificaciones de eventos externos.
RNF-09.1	Confiabilidad	Garantiza consistencia e integridad de datos.
RNF-09.2	Confiabilidad	Procesos críticos se ejecutan de forma transaccional.
RNF-10.1	Cumplimiento	Sigue convenciones de código C# y .NET.
RNF-10.2	Cumplimiento	Estructura preparada para versionado de API.
RNF-10.3	Cumplimiento	Documentación XML y README incluidos.
