using Google.Cloud.Firestore;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;

namespace ProyectoWeb.Data
{
    /// <summary>
    /// Servicio para gestionar la conexión con Firebase Firestore
    /// </summary>
    public class FirebaseService
    {
        private readonly FirestoreDb _firestoreDb;
        private static FirebaseService? _instance;
        private static readonly object _lock = new object();

        private FirebaseService(IConfiguration configuration)
        {
            try
            {
                // Obtener configuración desde appsettings.json
                var projectId = configuration["Firebase:ProjectId"];
                var credentialsPath = configuration["Firebase:CredentialsPath"];

                if (string.IsNullOrEmpty(projectId))
                {
                    throw new InvalidOperationException("Firebase ProjectId no está configurado en appsettings.json");
                }

                // Configurar la variable de entorno para las credenciales
                if (!string.IsNullOrEmpty(credentialsPath))
                {
                    if (!File.Exists(credentialsPath))
                    {
                        throw new FileNotFoundException("El archivo de credenciales de Firebase no existe");
                    }
                    Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);
                }

                // Crear instancia de FirestoreDb
                _firestoreDb = FirestoreDb.Create(projectId);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Error al inicializar Firebase", ex);
            }
        }

        /// <summary>
        /// Obtiene la instancia singleton del servicio Firebase
        /// </summary>
        public static FirebaseService GetInstance(IConfiguration configuration)
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = new FirebaseService(configuration);
                    }
                }
            }
            return _instance;
        }

        /// <summary>
        /// Obtiene la instancia de FirestoreDb para realizar operaciones
        /// </summary>
        public FirestoreDb GetFirestoreDb()
        {
            return _firestoreDb;
        }

        
        /// <param name="collectionName">Nombre de la colección</param>
        /// <returns>CollectionReference</returns>
        public CollectionReference GetCollection(string collectionName)
        {
            return _firestoreDb.Collection(collectionName);
        }
    }
}
