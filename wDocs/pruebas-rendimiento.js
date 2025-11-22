// Pruebas de rendimiento con k6
// Ejecutar: k6 run pruebas-rendimiento.js

import http from 'k6/http';
import { check, sleep } from 'k6';

// Configuración de la prueba
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Rampa hasta 10 usuarios en 30s
    { duration: '1m', target: 50 },   // Rampa hasta 50 usuarios en 1 minuto
    { duration: '2m', target: 50 },   // Mantiene 50 usuarios por 2 minutos
    { duration: '30s', target: 0 },   // Baja a 0 usuarios en 30s
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% de requests < 500ms
    http_req_failed: ['rate<0.1'],    // Menos del 10% de errores
  },
};

const BASE_URL = 'http://localhost:5000';

export default function () {
  // 1. Test: Página de inicio
  let response = http.get(`${BASE_URL}/`);
  check(response, {
    'Inicio status 200': (r) => r.status === 200,
  });

  sleep(1);

  // 2. Test: Login
  const loginPayload = JSON.stringify({
    nombreUsuario: 'admin',
    password: 'admin123',
  });

  response = http.post(`${BASE_URL}/api/auth/login`, loginPayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(response, {
    'Login status 200': (r) => r.status === 200,
    'Token recibido': (r) => r.json('token') !== undefined,
  });

  sleep(1);

  // 3. Test: Obtener productos
  response = http.get(`${BASE_URL}/api/producto`);
  check(response, {
    'Productos status 200': (r) => r.status === 200,
    'Productos es array': (r) => Array.isArray(r.json()),
  });

  sleep(1);

  // 4. Test: Obtener servicios
  response = http.get(`${BASE_URL}/api/servicio`);
  check(response, {
    'Servicios status 200': (r) => r.status === 200,
  });

  sleep(2);
}

// Función que se ejecuta al final de la prueba
export function handleSummary(data) {
  return {
    'reporte-rendimiento.html': htmlReport(data),
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
  };
}

function htmlReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
  <title>Reporte de Rendimiento</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    .pass { color: green; font-weight: bold; }
    .fail { color: red; font-weight: bold; }
  </style>
</head>
<body>
  <h1>📊 Reporte de Pruebas de Rendimiento</h1>
  <h2>Resumen</h2>
  <table>
    <tr>
      <th>Métrica</th>
      <th>Valor</th>
    </tr>
    <tr>
      <td>Total de Requests</td>
      <td>${data.metrics.http_reqs.values.count}</td>
    </tr>
    <tr>
      <td>Requests Fallidos</td>
      <td>${data.metrics.http_req_failed.values.passes}</td>
    </tr>
    <tr>
      <td>Duración Promedio</td>
      <td>${data.metrics.http_req_duration.values.avg.toFixed(2)} ms</td>
    </tr>
    <tr>
      <td>Duración p95</td>
      <td>${data.metrics.http_req_duration.values['p(95)'].toFixed(2)} ms</td>
    </tr>
    <tr>
      <td>Duración Máxima</td>
      <td>${data.metrics.http_req_duration.values.max.toFixed(2)} ms</td>
    </tr>
  </table>
</body>
</html>
  `;
}

function textSummary(data, opts) {
  return `
📊 RESUMEN DE PRUEBAS DE RENDIMIENTO
=========================================
Total Requests: ${data.metrics.http_reqs.values.count}
Requests Fallidos: ${data.metrics.http_req_failed.values.passes}
Duración Promedio: ${data.metrics.http_req_duration.values.avg.toFixed(2)} ms
Duración p95: ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)} ms
Duración Máxima: ${data.metrics.http_req_duration.values.max.toFixed(2)} ms
  `;
}
