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
    // Declaramos la variable AFUERA para que el catch la pueda ver
    string credentialsPath = "No definida"; 

    try
    {
        var projectId = configuration["Firebase:ProjectId"];
        
        // Intentamos obtener la ruta base
        string basePath = AppDomain.CurrentDomain.BaseDirectory;
        credentialsPath = Path.Combine(basePath, "firebase-credentials.json");

        if (string.IsNullOrEmpty(projectId))
        {
            throw new InvalidOperationException("Falta ProjectId");
        }

        if (!File.Exists(credentialsPath))
        {
             // Intento alternativo con ruta fija de SmarterASP (ajústala si tu ID es diferente)
             string fixedPath = @"h:\root\home\proyectotaller-001\www\site1\firebase-credentials.json";
             if (File.Exists(fixedPath))
             {
                 credentialsPath = fixedPath;
             }
             else 
             {
                 throw new FileNotFoundException($"No encuentro el JSON en: {credentialsPath} ni en {fixedPath}");
             }
        }
        
        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);

        _firestoreDb = FirestoreDb.Create(projectId);
    }
    catch (Exception ex)
    {
        // Ahora sí funcionará esto:
        throw new Exception($"Error Firebase CRÍTICO. Ruta final: {credentialsPath}. Detalle: {ex.Message}", ex);
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

        /// <summary>
        /// Obtiene una referencia a una colección específica
        /// </summary>
        /// <param name="collectionName">Nombre de la colección</param>
        /// <returns>CollectionReference</returns>
        public CollectionReference GetCollection(string collectionName)
        {
            return _firestoreDb.Collection(collectionName);
        }
    }
}
