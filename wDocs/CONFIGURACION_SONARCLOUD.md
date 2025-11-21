# Configuración de SonarCloud - Exclusión de Bibliotecas

## Problema
SonarCloud analiza **todas** las líneas de código incluyendo bibliotecas de terceros (Bootstrap, jQuery, etc.), lo que resulta en un conteo inflado (ej: 34,883 líneas cuando el código propio es ~4,000 líneas).

## Solución

### Opción 1: Usar archivo sonar-project.properties (Recomendado)

El archivo `sonar-project.properties` ya está creado en la raíz del proyecto con las exclusiones necesarias.

**Para aplicarlo en GitHub:**
1. Commit y push del archivo:
   ```bash
   git add sonar-project.properties
   git commit -m "Add SonarCloud configuration with exclusions"
   git push
   ```

2. SonarCloud detectará automáticamente el archivo en el próximo análisis

### Opción 2: Configurar desde la Web de SonarCloud

1. Ve a: https://sonarcloud.io/project/administration/settings?id=CamiLoP19_ProyectoWeb-TallerMecanico

2. En la sección **Analysis Scope** → **Source File Exclusions**, agrega:
   ```
   **/wwwroot/lib/**
   **/wwwroot/js/bootstrap*.js
   **/wwwroot/js/jquery*.js
   **/wwwroot/css/bootstrap*.css
   **/obj/**
   **/bin/**
   **/*.min.js
   **/*.min.css
   ```

3. Click **Save**

4. Re-analiza el proyecto (se puede hacer manualmente o esperar el siguiente commit)

### Opción 3: Configurar en GitHub Actions

Si usas GitHub Actions, agrega al archivo `.github/workflows/sonarcloud.yml`:

```yaml
- name: SonarCloud Scan
  uses: SonarSource/sonarcloud-github-action@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  with:
    args: >
      -Dsonar.exclusions=**/wwwroot/lib/**,**/wwwroot/js/bootstrap*.js,**/obj/**,**/bin/**,**/*.min.js,**/*.min.css
```

## Archivos que se Excluyen

| Patrón | Razón |
|--------|-------|
| `**/wwwroot/lib/**` | Bibliotecas de terceros (Bootstrap, jQuery, etc.) |
| `**/*.min.js` | JavaScript minificado de producción |
| `**/*.min.css` | CSS minificado de producción |
| `**/obj/**` | Archivos compilados temporales |
| `**/bin/**` | Binarios compilados |
| `**/node_modules/**` | Dependencias de Node.js |
| `**/.vs/**` | Archivos de Visual Studio |

## Resultado Esperado

**Antes de exclusiones:**
- LOC: ~34,883 (incluyendo todas las bibliotecas)

**Después de exclusiones:**
- LOC: ~3,862 (solo código propio del proyecto)

## Verificación

Después de aplicar las exclusiones:

1. Ve a: https://sonarcloud.io/project/overview?id=CamiLoP19_ProyectoWeb-TallerMecanico

2. Verifica que "Lines of Code" muestre un número razonable (~3,000-4,000)

3. Revisa la distribución por lenguaje - C# debe ser >80%

## Notas

- Las exclusiones NO afectan el funcionamiento de la aplicación
- Solo afectan qué archivos analiza SonarCloud
- Es una práctica estándar excluir bibliotecas de terceros
- Mejora la precisión de las métricas de calidad

## Re-analizar Manualmente

Si quieres forzar un nuevo análisis después de cambiar la configuración:

```bash
# Hacer un commit vacío para triggerar análisis
git commit --allow-empty -m "Trigger SonarCloud re-analysis"
git push
```

O desde la web de SonarCloud:
- Project Settings → Analysis Method → Re-analyze
