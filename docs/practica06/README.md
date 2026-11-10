# Práctica 06 — Cinemapedia

Cinemapedia es una aplicación Flutter para consultar y explorar películas y series mediante la API de [The Movie Database (TMDB)](https://www.themoviedb.org/). El proyecto aplica una arquitectura por capas para separar la lógica de dominio, el acceso a datos y la interfaz de usuario.

## Funcionalidades

- Catálogo de películas populares y estrenos con carga progresiva.
- Búsqueda de películas y consulta de información detallada.
- Reproducción de tráileres mediante YouTube.
- Selección regional con idioma y contenido adaptado por país.
- Reseñas locales persistentes para cada película.
- Interfaz Material 3 adaptable, carruseles y animaciones.
- Favoritos persistentes con Drift/SQLite y cuadrícula Masonry paginada.
- Rutas `/home`, `/categories`, `/favorites` mediante ShellRoute y detalle `/movie/:id`.
- Consulta y caché en memoria de detalles por ID, reparto y películas similares.
- Búsqueda con debounce de 350 ms y conservación de consulta y resultados durante la sesión.
- Scroll horizontal progresivo, bloqueo de peticiones simultáneas y reintento sin saltar páginas.
- Selector superior Películas / Series. Las series incluyen catálogo, búsqueda, temporadas, episodios, reparto, clasificación, videos, recomendaciones, favoritos y reseñas.
- El feed conserva su desplazamiento al volver de Favoritos. Películas y Series recuerdan posiciones independientes durante la sesión.
- Paleta azul estable y tipografía Roboto. El cambio de idioma usa desenfoque suave y una tarjeta de progreso; espera a la carga real con una transición mínima de 650 ms.

## Capturas de la aplicación

<table>
  <tr>
    <td align="center"><strong>Pantalla de inicio</strong></td>
    <td align="center"><strong>Catálogo regional</strong></td>
    <td align="center"><strong>Búsqueda</strong></td>
  </tr>
  <tr>
    <td><img src="screenshots/inicio.png" alt="Pantalla de inicio de Cinemapedia" width="230"></td>
    <td><img src="screenshots/catalogo.png" alt="Catálogo regional de películas" width="230"></td>
    <td><img src="screenshots/busqueda.png" alt="Búsqueda de películas" width="230"></td>
  </tr>
  <tr>
    <td align="center"><strong>Detalle de película</strong></td>
    <td align="center"><strong>Menú de navegación</strong></td>
    <td align="center"><strong>Región e idioma</strong></td>
  </tr>
  <tr>
    <td><img src="screenshots/detalle.png" alt="Detalle, clasificación y sinopsis de una película" width="230"></td>
    <td><img src="screenshots/regiones.png" alt="Menú de navegación de Cinemapedia" width="230"></td>
    <td><img src="screenshots/paises.png" alt="Selector de región, idioma y clasificación" width="230"></td>
  </tr>
</table>

La pantalla principal reúne el carrusel destacado, el cine del país seleccionado y los próximos estrenos. La búsqueda muestra resultados con año y calificación; el detalle incorpora portada, favoritos, clasificación regional y sinopsis. Desde el menú se accede a categorías, favoritos, búsqueda y a la configuración de país e idioma.

## Tecnologías

- Flutter y Dart.
- Riverpod para estado e inyección de dependencias.
- GoRouter para navegación.
- Dio para consumir la API de TMDB.
- Drift/SQLite para favoritos; SharedPreferences para reseñas locales.
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

## Cobertura del curso y alcance de la revisión

Se contrastó el proyecto con el [temario público de DevTalles](https://cursos.devtalles.com/courses/flutter-movil-cero-a-experto?coupon=MARZO-BEST-2026) y se consultaron los archivos de las ramas del repositorio del instructor, especialmente [fin-seccion-17-drift](https://github.com/Klerith/flutter-cinemapedia/tree/fin-seccion-17-drift) y [fin-seccion-18](https://github.com/Klerith/flutter-cinemapedia/tree/fin-seccion-18). La consulta se hizo por archivos y metadatos de GitHub, sin clonar ni importar el historial del repositorio del instructor.

| Sección | Implementación |
| --- | --- |
| 12: Full App | Entidades, contratos, datasource TMDB, modelos, mapper, repositorio y Riverpod. |
| 13: Continuación | Carrusel, cuatro catálogos, números compactos, carga inicial y paginación horizontal protegida. |
| 14: Películas y actores | Ruta por ID, modelo y mapper de detalle, caché de Riverpod, sinopsis, géneros y reparto. |
| 15: Búsquedas | SearchDelegate, debounce, carga/error/reintento y resultados retenidos en providers. |
| 16: ShellRoutes | StatefulShellRoute.indexedStack y vistas Inicio, Categorías y Favoritos. Conserva el estado entre pestañas y la pantalla de origen al volver del detalle. |
| 17: Local Databases | Drift/SQLite, contratos de almacenamiento, datasource y repositorio, favoritos por ID y cuadrícula Masonry paginada. |
| 18: Estudios adicionales | Vista de populares con Masonry y scroll infinito, películas similares y videos de YouTube con entidad, modelo, mapper, datasource, repositorio y providers. |

Se conservaron las funciones propias del proyecto: regiones e idiomas, reseñas y tráileres. También se incorporaron películas similares. No se modificó el progreso de las lecciones en el portal.

La vista de populares se encuentra dentro de Categorías, junto con las mejor calificadas y próximos estrenos. `/popular` redirige a esta pantalla. Se reutiliza el mismo widget Masonry en catálogos y favoritos. Los videos priorizan el tráiler oficial en español y permiten reproducir el primer video de YouTube disponible si no existe tráiler.

La rama `fin-seccion-18` del instructor conserva la implementación antigua de Isar. Esta práctica integra sus funciones sobre Drift, conforme a las lecciones actualizadas de la sección 17. Los nombres de rutas y componentes se adaptan a la app existente; no se reemplaza el proyecto por el del instructor.

Los favoritos conservan los datos de la película para consultarlos sin conexión. Las consultas de TMDB y la búsqueda requieren red; la caché de detalles y búsquedas dura mientras vive el contenedor de Riverpod.

Para regenerar los archivos de Drift después de cambiar el esquema:

```powershell
dart run build_runner build
```

La plataforma configurada en este repositorio es Android. La base de datos usa `drift_flutter`; una futura versión web necesita los recursos WebAssembly y el worker de Drift antes de poder ejecutarse.

## Series y conservación del estado

Las series usan los endpoints `/tv/on_the_air`, `/tv/popular`, `/tv/top_rated`, `/tv/airing_today`, `/search/tv` y `/tv/:id` con el idioma seleccionado. «En emisión» corresponde a la programación de la semana y «Episodios de hoy» a las series con emisiones del día. El detalle tiene su propia ruta `/series/:id`.

La base de datos v2 identifica favoritos mediante el tipo de contenido y el ID de TMDB. La migración desde v1 conserva los favoritos de películas. Las reseñas de películas conservan sus claves anteriores; las de series usan claves distintas. Así, una serie y una película con el mismo número de ID no comparten favoritos ni comentarios.

`StatefulShellRoute.indexedStack` mantiene las pestañas montadas. Cada feed tiene una clave de almacenamiento de desplazamiento por tipo y región, por lo que cambiar de pestaña no reinicia la lista ni su posición. Este estado dura durante la sesión; no se promete restaurar el scroll después de cerrar la app.
