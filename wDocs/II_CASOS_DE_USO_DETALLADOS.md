👤 CASOS DE USO - CLIENTE
CU-01: Registrarse
Actor Principal: Cliente (público sin autenticación)
Objetivo: Crear una cuenta de cliente en el sistema.
Precondiciones:

El usuario no debe tener una cuenta previa
El nombre de usuario debe ser único

Flujo Principal:

El cliente accede a la página de registro
El sistema muestra el formulario de registro
El cliente ingresa nombre de usuario, contraseña, correo electrónico y nombre completo
El cliente hace clic en "Registrarse"
El sistema valida que el nombre de usuario no exista en todo el sistema
El sistema valida que el correo electrónico no exista en todo el sistema
El sistema crea el usuario con rol Cliente en Firebase
El sistema asigna fecha de creación UTC
El sistema retorna el usuario creado
El sistema redirige al login

Flujos Alternativos:
FA-01: Nombre de usuario ya existe

Si el nombre ya existe en usuarios o empleados, el sistema muestra mensaje de error y solicita ingresar otro nombre

FA-02: Correo electrónico ya existe

Si el correo ya existe en usuarios o empleados, el sistema muestra mensaje de error y solicita ingresar otro correo

FA-03: Error de validación

Si faltan campos requeridos, el sistema muestra los campos faltantes y el usuario corrige y reintenta

Postcondiciones:

Usuario creado en la base de datos
Usuario puede iniciar sesión
Rol asignado: Cliente
Estado: Activo


CU-02: Iniciar Sesión
Actor Principal: Cliente, Empleado o Administrador
Objetivo: Autenticarse en el sistema para acceder a funcionalidades según rol.
Precondiciones:

El usuario debe estar registrado en el sistema
El usuario debe estar activo

Flujo Principal:

El usuario accede a la página de login
El sistema muestra formulario de login
El usuario ingresa nombre de usuario y contraseña
El usuario hace clic en "Iniciar Sesión"
El sistema busca el usuario en Firebase por nombre de usuario
El sistema verifica la contraseña
El sistema obtiene el rol del usuario
El sistema crea respuesta con datos del usuario
El sistema actualiza el estado de autenticación con la sesión
El sistema redirige según rol:

Administrador → Dashboard Admin
Empleado → Dashboard Empleado
Cliente → Página Principal



Flujos Alternativos:
FA-01: Credenciales incorrectas

Si usuario o contraseña incorrectos, el sistema muestra mensaje de error y permanece en página de login

FA-02: Usuario inactivo

Si el usuario está desactivado, el sistema muestra mensaje de error y no permite acceso

FA-03: Error del servidor

Si hay error en Firebase, el sistema muestra mensaje de error y registra el error en logs

Postcondiciones:

Usuario autenticado en el sistema
Sesión activa almacenada en navegador
Estado de autenticación actualizado
Usuario redirigido a su dashboard correspondiente


CU-03: Solicitar Servicio
Actor Principal: Cliente
Objetivo: Crear una nueva solicitud de servicio para el taller.
Precondiciones:

El cliente debe estar autenticado
El cliente debe tener rol Cliente

Flujo Principal:

El cliente accede a la página de servicios
El sistema muestra formulario de nueva solicitud
El cliente ingresa descripción del problema y detalle adicional (opcional)
El cliente hace clic en "Crear Solicitud"
El sistema obtiene el ClienteId de la sesión
El sistema obtiene el nombre del cliente
El sistema crea la solicitud con estado Pendiente, sin empleado asignado y fecha actual
El sistema guarda en la base de datos
El sistema retorna la solicitud creada
El sistema actualiza la lista de solicitudes del cliente
El sistema muestra mensaje de éxito

Flujos Alternativos:
FA-01: Descripción vacía

Si falta descripción, el sistema muestra mensaje de error y solicita completar el campo

FA-02: Error al guardar

Si hay error en Firebase, el sistema muestra mensaje de error y registra el error en logs

Postcondiciones:

Solicitud creada en la base de datos
Estado: Pendiente
Visible para empleados en lista de pendientes
Cliente puede ver su solicitud en "Mis Solicitudes"


CU-04: Ver Solicitudes
Actor Principal: Cliente
Objetivo: Consultar el listado de solicitudes propias del cliente.
Precondiciones:

El cliente debe estar autenticado
El cliente debe tener rol Cliente

Flujo Principal:

El cliente accede a la página de servicios
El sistema obtiene el ClienteId de la sesión
El sistema consulta Firebase filtrando por ClienteId
El sistema retorna lista de solicitudes ordenadas por fecha descendente
El sistema muestra tabla con fecha, descripción, estado, empleado asignado y acciones disponibles

Flujos Alternativos:
FA-01: No hay solicitudes

Si lista vacía, el sistema muestra mensaje informativo y ofrece botón para crear nueva solicitud

FA-02: Error al cargar

Si hay error, el sistema muestra mensaje de error y ofrece botón para reintentar

Postcondiciones:

Lista de solicitudes mostrada
Cliente puede ver estado actual de cada solicitud
Cliente puede acceder a detalles de cada solicitud


CU-05: Ver Detalle de Solicitud
Actor Principal: Cliente, Empleado
Objetivo: Consultar información detallada de una solicitud específica.
Precondiciones:

El actor debe estar autenticado
La solicitud debe existir
El actor debe tener permiso (cliente=propietario, empleado=asignado, admin=todos)

Flujo Principal:

El actor hace clic en una solicitud de la lista
El sistema busca la solicitud en Firebase por ID
El sistema verifica permisos de acceso
El sistema retorna la solicitud completa
El sistema muestra información del cliente, descripción, estado, empleado asignado, servicio asociado, fechas e historial de cambios

Flujos Alternativos:
FA-01: Solicitud no encontrada

Si no existe, el sistema muestra mensaje de error

FA-02: Sin permisos

Si no tiene acceso, el sistema muestra mensaje de acceso denegado

Postcondiciones:

Detalles completos mostrados
Información actualizada


CU-06: Ver Facturas
Actor Principal: Cliente
Objetivo: Consultar el listado de facturas del cliente.
Precondiciones:

El cliente debe estar autenticado
El cliente debe tener rol Cliente

Flujo Principal:

El cliente accede a la sección de facturas
El sistema obtiene el ClienteId de la sesión
El sistema consulta Firebase filtrando por ClienteId
El sistema retorna lista de facturas
El sistema muestra tabla con número de factura, fecha, servicio, empleado, total, saldo pendiente, estado, código de barras y opciones disponibles

Flujos Alternativos:
FA-01: No hay facturas

Si lista vacía, el sistema muestra mensaje informativo

Postcondiciones:

Lista de facturas mostrada
Cliente puede ver estado de pagos
Cliente puede proceder a pagar facturas pendientes


CU-07: Pagar Factura
Actor Principal: Cliente
Objetivo: Realizar el pago total o parcial de una factura.
Precondiciones:

El cliente debe estar autenticado
La factura debe existir y tener saldo pendiente
La factura debe pertenecer al cliente

Flujo Principal:

El cliente selecciona una factura pendiente
El sistema muestra opciones de pago: pago en línea con Stripe o registrar abono manual

Opción A: Pago en línea con Stripe
3. El cliente hace clic en "Pagar con tarjeta"
4. El sistema crea sesión de pago en Stripe con monto, moneda MXN, metadata y URLs de éxito/cancelación
5. El sistema retorna URL de pago de Stripe
6. El cliente es redirigido a Stripe Checkout
7. El cliente ingresa datos de tarjeta y confirma
8. Stripe procesa el pago
9. Stripe envía webhook al sistema
10. El sistema valida firma del webhook
11. El sistema extrae facturaId y monto
12. El sistema crea abono automáticamente
13. El sistema actualiza saldo de la factura
14. Si saldo es cero, marca factura como Pagada
15. El sistema redirige al cliente a página de éxito
Opción B: Registrar abono manual
3. El cliente ingresa monto del abono, método de pago y observaciones opcionales
4. El cliente hace clic en "Registrar Abono"
5. El sistema valida que monto sea menor o igual al saldo pendiente
6. El sistema crea el abono con fecha actual
7. El sistema actualiza saldo restando el monto del abono
8. Si saldo es cero, marca factura como pagada con fecha de pago actual
9. El sistema guarda cambios en Firebase
10. El sistema muestra confirmación
Flujos Alternativos:
FA-01: Pago rechazado en Stripe

Si Stripe rechaza el pago, el sistema redirige a URL de cancelación y muestra mensaje informativo

FA-02: Monto de abono inválido

Si monto es mayor al saldo, el sistema muestra mensaje de error
Si monto es menor o igual a cero, el sistema muestra mensaje de error

FA-03: Factura ya pagada

Si la factura ya está pagada, el sistema muestra mensaje de error

Postcondiciones:

Abono registrado en la base de datos
Saldo de factura actualizado
Si pago completo: factura marcada como pagada
Cliente recibe confirmación
Sistema registra transacción en logs


👷 CASOS DE USO - EMPLEADO
CU-08: Listar Solicitudes Pendientes
Actor Principal: Empleado
Objetivo: Ver todas las solicitudes que no han sido asignadas a ningún empleado.
Precondiciones:

El empleado debe estar autenticado
El empleado debe tener rol Empleado
El empleado debe estar activo

Flujo Principal:

El empleado accede al dashboard
El sistema consulta Firebase con filtros: Estado Pendiente y sin empleado asignado
El sistema ordena por fecha de solicitud descendente
El sistema retorna lista de solicitudes pendientes
El sistema muestra tabla con fecha, cliente, descripción, detalle y botón para tomar solicitud

Flujos Alternativos:
FA-01: No hay solicitudes pendientes

Si lista vacía, el sistema muestra mensaje informativo y el empleado puede ver sus solicitudes asignadas

Postcondiciones:

Lista de solicitudes pendientes mostrada
Empleado puede tomar cualquier solicitud


CU-09: Atender Solicitud
Actor Principal: Empleado
Objetivo: Asignar una solicitud pendiente a sí mismo y cambiar su estado a "En Proceso".
Precondiciones:

El empleado debe estar autenticado
La solicitud debe existir y estar en estado Pendiente
La solicitud no debe tener empleado asignado

Flujo Principal:

El empleado visualiza lista de solicitudes pendientes
El empleado selecciona una solicitud
El empleado hace clic en "Tomar Solicitud"
El sistema obtiene el EmpleadoId de la sesión
El sistema obtiene el nombre del empleado
El sistema actualiza la solicitud asignando empleado, cambiando estado a En Proceso y registrando fecha de asignación
El sistema guarda cambios en Firebase
El sistema retorna confirmación
El sistema actualiza las listas: remueve de pendientes y agrega a solicitudes asignadas
El sistema muestra mensaje de éxito
El empleado puede comenzar a trabajar en la solicitud

Flujos Alternativos:
FA-01: Solicitud ya asignada

Si ya tiene empleado, el sistema muestra mensaje de error y actualiza lista de pendientes

FA-02: Solicitud no existe

Si no se encuentra, el sistema muestra mensaje de error

Postcondiciones:

Solicitud asignada al empleado
Estado cambiado a En Proceso
Solicitud visible en dashboard del empleado
Cliente puede ver que su solicitud está siendo atendida


CU-10: Generar Factura
Actor Principal: Empleado
Objetivo: Crear una factura por el servicio completado, incluyendo productos utilizados.
Precondiciones:

El empleado debe estar autenticado
La solicitud debe estar asignada al empleado
La solicitud debe estar en estado En Proceso
Debe existir el servicio asociado

Flujo Principal:

El empleado accede a la página de generar factura
El empleado selecciona la solicitud completada
El sistema carga información de la solicitud: cliente, servicio y precio
El empleado agrega productos utilizados seleccionando del catálogo e ingresando cantidad
El sistema calcula subtotal por cada producto y puede agregar múltiples productos
El sistema muestra resumen con precio del servicio, productos, subtotal, comisión del empleado y total
El empleado hace clic en "Generar Factura"
El sistema valida stock de productos
El sistema crea factura con número generado automáticamente, información completa del cliente y empleado, servicio, productos, cálculos financieros y estado inicial
El sistema genera código de barras del número de factura
El sistema actualiza stock de productos descontando cantidades utilizadas
El sistema marca solicitud como Completada con fecha
El sistema guarda factura en la base de datos
El sistema envía factura por email al cliente de forma asíncrona
El sistema retorna factura creada
El sistema muestra confirmación con número de factura
El sistema permite imprimir o descargar factura

Flujos Alternativos:
FA-01: Stock insuficiente

Si no hay stock, el sistema muestra mensaje de error y el empleado debe ajustar cantidades o remover producto

FA-02: Error al generar código de barras

Si falla generación, el sistema registra warning en logs y la factura se crea sin código (puede regenerarse después)

FA-03: Error al enviar email

Si falla envío, el sistema registra warning en logs, la factura se crea exitosamente y el email puede reenviarse después

FA-04: Solicitud no encontrada

Si no existe, el sistema muestra mensaje de error

Postcondiciones:

Factura creada en la base de datos
Stock de productos actualizado (decrementado)
Solicitud marcada como Completada
Código de barras generado y almacenado
Email enviado al cliente con factura
Comisión del empleado registrada
Factura visible para cliente y admin


🔧 CASOS DE USO - ADMINISTRADOR
CU-11: Gestionar Empleados
Actor Principal: Administrador
Objetivo: Realizar operaciones CRUD sobre empleados del sistema.
Precondiciones:

El administrador debe estar autenticado
El administrador debe tener rol Administrador

Flujo Principal:
A. CREAR EMPLEADO

El admin accede a la página de empleados
El admin hace clic en "Nuevo Empleado"
El admin ingresa nombre de usuario único, contraseña, correo electrónico, nombre completo y porcentaje de comisión
El admin hace clic en "Guardar"
El sistema valida que nombre de usuario no exista en todo el sistema
El sistema valida que correo electrónico no exista en todo el sistema
El sistema crea empleado con rol Empleado, estado activo y fecha de creación
El sistema guarda en la base de datos
El sistema actualiza tabla de empleados
El sistema muestra mensaje de éxito

B. LISTAR EMPLEADOS

El admin accede a la página de empleados
El sistema consulta todos los empleados de Firebase
El sistema muestra tabla con nombre completo, usuario, correo, comisión, estado y acciones

C. ACTUALIZAR EMPLEADO

El admin hace clic en "Editar" de un empleado
El sistema carga datos actuales
El admin modifica campos deseados
El admin hace clic en "Actualizar"
El sistema actualiza fecha de modificación y campos modificados
El sistema guarda cambios en Firebase
El sistema muestra confirmación

D. ELIMINAR EMPLEADO

El admin hace clic en "Eliminar"
El sistema solicita confirmación
El admin confirma
El sistema realiza eliminación lógica marcando como inactivo
El sistema actualiza en Firebase
El sistema actualiza tabla
El sistema muestra confirmación

Flujos Alternativos:
FA-01: Nombre de usuario duplicado

Si existe en usuarios o empleados, el sistema muestra mensaje de error

FA-02: Correo electrónico duplicado

Si existe en usuarios o empleados, el sistema muestra mensaje de error

FA-03: Empleado no encontrado

Si no existe, el sistema muestra mensaje de error

FA-04: Cancelar operación

Usuario puede cancelar en cualquier momento sin guardar cambios

Postcondiciones:

Empleados gestionados correctamente
Cambios reflejados en Firebase
Lista actualizada en interfaz


CU-12: Gestionar Productos
Actor Principal: Administrador
Objetivo: Realizar operaciones CRUD sobre productos del inventario.
Precondiciones:

El administrador debe estar autenticado
El administrador debe tener rol Administrador

Flujo Principal:
A. CREAR PRODUCTO

El admin accede a la página de productos
El admin hace clic en "Nuevo Producto"
El admin ingresa nombre, descripción opcional, precio y stock inicial
El admin hace clic en "Guardar"
El sistema crea producto con estado activo y fecha de creación
El sistema guarda en la base de datos
El sistema actualiza tabla
El sistema muestra confirmación

B. LISTAR PRODUCTOS

El admin accede a la página de productos
El sistema consulta productos activos
El sistema muestra tabla con nombre, descripción, precio, stock actual, estado y acciones

C. ACTUALIZAR PRODUCTO

El admin hace clic en "Editar"
El sistema carga datos actuales
El admin modifica campos
El admin hace clic en "Actualizar"
El sistema actualiza fecha de modificación y campos modificados
El sistema guarda en Firebase

D. ACTUALIZAR STOCK

El admin hace clic en "Actualizar Stock"
El admin ingresa nuevo valor de stock
El admin confirma
El sistema actualiza stock en Firebase
El sistema muestra nuevo stock

E. ELIMINAR PRODUCTO

El admin hace clic en "Eliminar"
El sistema solicita confirmación
El admin confirma
El sistema realiza eliminación lógica marcando como inactivo
El sistema actualiza en Firebase

Flujos Alternativos:
FA-01: Precio o stock inválido

Si precio o stock son menores a cero, el sistema muestra mensaje de error

FA-02: Producto en uso

Al eliminar producto usado en facturas, el sistema desactiva en lugar de eliminar para mantener histórico

Postcondiciones:

Productos gestionados
Inventario actualizado
Cambios en Firebase



CU-13: Ver Reportes y Ganancias
Actor Principal: Administrador
Objetivo: Consultar reportes financieros y ganancias del taller con opción de exportar a PDF.
Precondiciones:
•	El administrador debe estar autenticado
•	El administrador debe tener rol Administrador
•	Debe haber facturas registradas en el sistema
Flujo Principal:
1.	El admin accede a la sección de reportes
2.	El admin selecciona período: mes específico o año completo
3.	El admin hace clic en "Generar Reporte"
4.	El sistema consulta todas las facturas del período en Firebase
5.	El sistema calcula total de facturas, facturas pagadas vs pendientes, ganancia por servicios y productos, total de comisiones, total ganado y ganancia neta
6.	El sistema genera objeto con información del reporte
7.	El sistema muestra dashboard con gráficos, tabla de desglose, comparativa de períodos y top servicios/productos
8.	El admin puede hacer clic en “imprimir  PDF"
9.	El sistema genera PDF con logo del taller, información del reporte, tablas, gráficos y resumen ejecutivo
10.	El admin guarda el archivo como PDF
Flujos Alternativos:
FA-01: No hay datos en el período
•	Si no hay facturas, el sistema muestra mensaje informativo con reporte vacío o con ceros
FA-02: Error al generar PDF
•	Si falla generación, el sistema muestra mensaje de error y ofrece opciones: ver en pantalla, exportar a CSV o reintentar
FA-03: Consulta de año completo
•	Si se selecciona año sin mes, el sistema consolida datos de todos los meses y muestra comparativa mensual
Postcondiciones:
Reporte generado y mostrado
Admin tiene visibilidad de finanzas
PDF disponible para archivo
Datos actualizados en tiempo real

