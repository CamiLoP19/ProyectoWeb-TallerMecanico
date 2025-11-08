# Proyecto Web - Sistema de Gestión con ASP.NET Core + Blazor Server

Este proyecto es la migración de la aplicación de escritorio a una aplicación web moderna utilizando ASP.NET Core, Blazor Server y Firebase Firestore como base de datos.

## 📋 Estructura del Proyecto

```
ProyectoWeb/
├── Controllers/          # Controladores API REST
│   └── EmpleadoController.cs
├── Services/            # Lógica de negocio
│   └── EmpleadoService.cs
├── Models/              # Entidades con anotaciones Firestore
│   ├── Usuario.cs
│   └── Empleado.cs
├── Data/                # Conexión a Firebase
│   └── FirebaseService.cs
├── Pages/               # Páginas Blazor
│   ├── Index.razor
│   ├── Empleados.razor
│   ├── _Host.cshtml
│   └── _Imports.razor
├── Shared/              # Componentes compartidos
│   ├── App.razor
│   ├── MainLayout.razor
│   └── NavMenu.razor
└── wwwroot/             # Archivos estáticos
    └── css/
        └── site.css
```

## 🚀 Características

- **Backend API REST**: Controllers con endpoints para CRUD completo
- **Frontend Blazor Server**: Interfaz de usuario reactiva adaptada del diseño XAML original
- **Firebase Firestore**: Base de datos NoSQL en la nube
- **Diseño Responsive**: Interfaz moderna con Bootstrap 5
- **Validaciones**: Validación de datos en cliente y servidor

## 📦 Requisitos Previos

1. **.NET 8.0 SDK** o superior
2. **Visual Studio 2022** o **Visual Studio Code**
3. **Cuenta de Firebase** (gratuita)

## 🔧 Configuración de Firebase

### Paso 1: Crear un proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Asigna un nombre a tu proyecto (ej: "proyecto-taller")
4. Sigue los pasos del asistente

### Paso 2: Habilitar Firestore

1. En el menú lateral, ve a **Build → Firestore Database**
2. Haz clic en "Crear base de datos"
3. Selecciona "Iniciar en modo de prueba" (para desarrollo)
4. Elige una ubicación cercana

### Paso 3: Obtener las credenciales

1. Ve a **Configuración del proyecto** (ícono de engranaje)
2. Ve a la pestaña **Cuentas de servicio**
3. Haz clic en **Generar nueva clave privada**
4. Se descargará un archivo JSON
5. **Guarda este archivo** como `firebase-credentials.json` en la raíz del proyecto `ProyectoWeb`

### Paso 4: Configurar appsettings.json

Edita el archivo `appsettings.json` con tu información:

```json
{
  "Firebase": {
    "ProjectId": "tu-proyecto-id",
    "CredentialsPath": "firebase-credentials.json"
  }
}
```

⚠️ **Importante**: 
- El `ProjectId` se encuentra en el archivo JSON descargado
- Nunca subas `firebase-credentials.json` a control de versiones
- Agrega `firebase-credentials.json` a tu `.gitignore`

## 🏃‍♂️ Ejecutar el Proyecto

### Opción 1: Visual Studio

1. Abre `ProyectoWeb.csproj` en Visual Studio 2022
2. Restaura los paquetes NuGet (automático)
3. Presiona **F5** para ejecutar

### Opción 2: Línea de comandos

```powershell
# Navegar a la carpeta del proyecto
cd ProyectoWeb

# Restaurar paquetes
dotnet restore

# Ejecutar la aplicación
dotnet run
```

La aplicación estará disponible en:
- **HTTPS**: https://localhost:7xxx
- **HTTP**: http://localhost:5xxx

(Los puertos exactos se mostrarán en la consola)

## 📱 Uso de la Aplicación

### Página Principal
- Accede a `https://localhost:7xxx/`
- Verás el menú de módulos disponibles

### Gestión de Empleados
- Accede a `https://localhost:7xxx/empleados`
- **Crear**: Haz clic en "Nuevo Empleado" y completa el formulario
- **Listar**: Verás todos los empleados activos en la tabla
- **Editar**: Haz clic en el botón "Editar" de un empleado
- **Eliminar**: Haz clic en el botón "Eliminar" (marca como inactivo)

## 🌐 API REST Endpoints

El backend expone los siguientes endpoints:

### Empleados

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/empleado` | Obtiene todos los empleados |
| GET | `/api/empleado/{id}` | Obtiene un empleado por ID |
| POST | `/api/empleado` | Crea un nuevo empleado |
| PUT | `/api/empleado/{id}` | Actualiza un empleado |
| DELETE | `/api/empleado/{id}` | Elimina un empleado |

### Ejemplo de uso con curl:

```bash
# Obtener todos los empleados
curl https://localhost:7xxx/api/empleado

# Crear un nuevo empleado
curl -X POST https://localhost:7xxx/api/empleado \
  -H "Content-Type: application/json" \
  -d '{
    "NombreUsuario": "jperez",
    "Password": "123456",
    "NombreCompleto": "Juan Pérez",
    "CorreoElectronico": "jperez@ejemplo.com",
    "PorcentajeComision": 0.60
  }'
```

## 📊 Modelo de Datos

### Empleado
```csharp
{
  "Id": "string",                    // ID del documento Firestore
  "NombreUsuario": "string",         // Único
  "Password": "string",
  "NombreCompleto": "string",
  "CorreoElectronico": "string",     // Único
  "PorcentajeComision": decimal,     // 0.0 a 1.0 (0% a 100%)
  "Rol": int,                        // 2 = Empleado
  "Activo": bool,                    // true/false
  "FechaCreacion": DateTime,
  "FechaModificacion": DateTime?
}
```

## 🎨 Adaptación del Diseño XAML a Blazor

El diseño se adaptó manteniendo la filosofía del original:

| XAML | Blazor |
|------|--------|
| `Window` | Página Razor |
| `StackPanel` | `div` con clases Bootstrap |
| `TextBox` | `InputText` con estilos similares |
| `Button` | `button` con clases Bootstrap |
| `DataGrid` | `table` con Bootstrap |

Los estilos en `site.css` recrean el look original:
- Fuente Montserrat
- Bordes inferiores en inputs (estilo Material)
- Botones con gradientes
- Animaciones y transiciones

## 🔐 Reglas de Seguridad de Firestore (Producción)

Para producción, actualiza las reglas en Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura/escritura solo a usuarios autenticados
    match /empleados/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🚧 Próximos Pasos

Para completar la migración, considera implementar:

1. **Autenticación**: Firebase Authentication para login
2. **Otros CRUDs**: Productos, Facturas, Servicios, etc.
3. **Validaciones**: Data Annotations en los modelos
4. **Manejo de errores**: Middleware para errores globales
5. **Paginación**: Para listados grandes
6. **Búsqueda y filtros**: En las tablas
7. **Exportación**: PDF/Excel de reportes
8. **Tests**: Pruebas unitarias y de integración

## 📚 Recursos Adicionales

- [Documentación ASP.NET Core](https://docs.microsoft.com/aspnet/core/)
- [Documentación Blazor](https://docs.microsoft.com/aspnet/core/blazor/)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Bootstrap 5](https://getbootstrap.com/docs/5.3/)

## ⚠️ Notas Importantes

1. **Seguridad**: Nunca expongas las credenciales de Firebase en el código
2. **Contraseñas**: Implementa hashing (BCrypt, PBKDF2) antes de guardar
3. **CORS**: Configura correctamente en producción
4. **HTTPS**: Usa siempre HTTPS en producción
5. **Backup**: Configura backups automáticos en Firebase

## 🐛 Solución de Problemas

### Error: "Firebase ProjectId no está configurado"
- Verifica que `appsettings.json` tenga el ProjectId correcto

### Error: "El archivo de credenciales no existe"
- Asegúrate de que `firebase-credentials.json` esté en la raíz
- Verifica la ruta en `appsettings.json`

### Error: "No se pueden cargar los empleados"
- Verifica que Firestore esté habilitado en Firebase Console
- Revisa las reglas de seguridad de Firestore
- Verifica la conexión a internet

## 📝 Licencia

Este proyecto es parte de un ejercicio académico.

---

**Desarrollado con ❤️ usando ASP.NET Core + Blazor + Firebase**
