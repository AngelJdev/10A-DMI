# Práctica 06 — Cinemapedia

Cinemapedia es una aplicación Flutter para consultar y explorar películas mediante la API de [The Movie Database (TMDB)](https://www.themoviedb.org/). El proyecto aplica una arquitectura por capas para separar la lógica de dominio, el acceso a datos y la interfaz de usuario.

## Funcionalidades

- Catálogo de películas populares y estrenos con carga progresiva.
- Búsqueda de películas y consulta de información detallada.
- Reproducción de tráileres mediante YouTube.
- Selección regional con idioma y contenido adaptado por país.
- Reseñas locales persistentes para cada película.
- Interfaz Material 3 adaptable, carruseles y animaciones.

## Tecnologías

- Flutter y Dart.
- Riverpod para estado e inyección de dependencias.
- GoRouter para navegación.
- Dio para consumir la API de TMDB.
- SharedPreferences para persistencia local.
- YouTube Player IFrame para reproducir tráileres.

## Arquitectura

El código de `lib` se organiza en tres capas principales:

```text
lib/
├── domain/          # Entidades y contratos de repositorios
├── infrastructure/  # API, modelos, mapeadores y repositorios
└── presentation/    # Pantallas, providers y widgets
```

## Configuración

La aplicación requiere una clave de TMDB. Crea el archivo `.env` en esta carpeta con el siguiente contenido:

```env
THE_MOVIEDB_KEY=tu_clave_de_tmdb
```

No publiques una clave real en el repositorio.

## Ejecución

Desde la raíz del repositorio:

```powershell
cd docs/practica06
flutter pub get
flutter run
```

Para ejecutar en un dispositivo específico:

```powershell
flutter devices
flutter run -d <id-del-dispositivo>
```

## Verificación

```powershell
flutter analyze
flutter test
```

Las pruebas cubren la conversión de respuestas de TMDB, el catálogo regional, las reseñas locales, el desplazamiento de títulos y los widgets principales.
