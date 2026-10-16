# Práctica 04 — TikiTiki (TikTok Clone con Clean Architecture)

> Aplicación móvil en Flutter que simula la experiencia central de la red social **TikTok**: reproducción de video vertical a pantalla completa, navegación fluida, arquitectura limpia desacoplada (**Clean Code**), gestión reactiva de estado con **Providers**, soporte de temas estacionales visuales y auditivos (**Halloween**, **Navidad**, **San Valentín** y **Normal**), persistencia en **Local Storage** y consumo multi-fuente (**Local**, **YouTube** y **Online Streams**).

- **Estudiante:** Angel de Jesus Baños Tellez
- **Matrícula:** 230592
- **Grupo:** 10A
- **Materia:** Desarrollo Móvil Integral (DMI)
- **Docente:** M.T.I. Marco A. Ramírez Hernández
- **Periodo:** Septiembre – Diciembre 2026

---

## 1. Objetivo de la Práctica

El estudiante realizará una aplicación básica que simule la funcionalidad esencial de la Red Social TikTok: la reproducción de videos con desplazamiento vertical fluido, incorporando widgets Stateless y Stateful, gestión de estado con Providers, arquitectura Clean Code por capas y persistencia local de interacciones.

### Conceptos Clave Incorporados

1. **Providers:** Gestión reactiva del estado de la aplicación mediante `MultiProvider`, `ChangeNotifierProvider`, `SeasonProvider` y `VideoFeedProvider`.
2. **Manejo de Assets:** Organización de recursos locales en `assets/videos/` (5 videos optimizados < 25 MB totales), `assets/images/` y `assets/audio/` (efectos de audio estacionales en formato WAV PCM de alta compatibilidad).
3. **Paquetes de Terceros:** Integración de `provider`, `video_player`, `youtube_player_flutter`, `shared_preferences`, `audioplayers` y `google_fonts`.
4. **Gesture Detector:** Control gestual para pausar/reproducir con un solo tap, dar me gusta instantáneo con doble tap y animación de corazón flotante, y toggles táctiles en botones flotantes.
5. **Posicionamiento de Widgets:** Empleo estricto de `Positioned`, `Positioned.fill` y `Align` para ubicar controles, contadores, descripciones e indicadores sin colisiones visuales.
6. **Mappers:** Transformación limpia de modelos de infraestructura (`VideoModel`) a entidades puras del dominio (`Video`) mediante `VideoMapper`.
7. **Gradientes:** Aplicación de `LinearGradient` superior para legibilidad de cabeceras y gradiente temático inferior acorde a la paleta de temporada.
8. **Loops:** Iteración sistemática de listas de datos en repositorios y bucles continuos de reproducción de video (`controller.setLooping(true)`) y rotación del disco de vinilo (`AnimationController.repeat()`).
9. **Aserciones:** Validación estricta en tiempo de construcción (`assert(id.isNotEmpty)`, `assert(likes >= 0)`, etc.) en modelos y entidades del dominio.
10. **Stacks:** Composición multicapa de video de fondo, sombras degradadas, controles interactivos y overlays informativos.
11. **Controladores de Video:** Manejo coordinado de `VideoPlayerController` (para assets locales y streams de red MP4) y `YoutubePlayerController` (para videos embebidos de YouTube).
12. **Clean Code & Clean Architecture:** Separación rigurosa de responsabilidades en capas `Domain`, `Data`, `Core` y `Presentation`.

---

## 2. Tecnologías Utilizadas

### Lenguajes y Frameworks

| Tecnología | Versión | Uso en el Proyecto |
|---|---:|---|
| **Flutter** | `3.47.5` (stable) | Framework de desarrollo multiplataforma y Material 3. |
| **Dart** | `3.13.4` | Lenguaje con Null Safety, asincronía (`async/await`) y programación funcional. |

### Paquetes (`pubspec.yaml`)

| Paquete | Versión | Función dentro del Proyecto |
|---|---:|---|
| `provider` | `^6.0.5` | Inyección de dependencias y reactividad (`SeasonProvider`, `VideoFeedProvider`). |
| `video_player` | `^2.14.1` | Reproducción de videos locales en assets y streams online de alta velocidad. |
| `youtube_player_flutter` | `^10.0.1` | Reproducción de contenido desde la API IFrame de YouTube. |
| `shared_preferences` | `^2.5.6` | Almacenamiento local persistente (conteo de likes, estado me gusta, favoritos y tema forzado). |
| `audioplayers` | `^6.8.1` | Reproducción de efectos de sonido temáticos al cambiar de temporada. |
| `google_fonts` | `^9.0.0` | Tipografías temáticas por temporada (`Creepster`, `Mountains of Christmas`, `Dancing Script`, `Inter`). |
| `cupertino_icons` | `^1.0.8` | Iconografía auxiliar del sistema. |
| `flutter_lints` | `^6.0.0` | Reglas de estilo y calidad de código ejecutadas con `flutter analyze`. |

---

## 3. Funcionalidades Específicas Implementadas

### A. Temas Visuales y Auditivos por Temporada

La aplicación adapta dinámicamente su paleta cromática, tipografía, iconografía y efectos de audio según la temporada:

| Temporada | Mes Automático | Tipografía (Google Fonts) | Paleta de Colores | Iconos Temáticos | Efecto de Audio |
|---|:---:|---|---|---|---|
| **🎃 Halloween** | Octubre (`10`) | `Creepster` / `Cinzel` | Naranja Calabaza (`#FF6B00`), Púrpura Místico (`#8A2BE2`), Verde Ectoplasma (`#39FF14`) | Murciélago / Luna (`Icons.nightlight_round`) | `assets/audio/halloween.wav` |
| **🎄 Navidad** | Diciembre (`12`) | `Mountains of Christmas` / `Quicksand` | Rojo Navideño (`#E50914`), Verde Pino (`#1E5128`), Dorado Campana (`#FFD700`) | Estrella (`Icons.star`), Regalo (`Icons.card_giftcard`) | `assets/audio/christmas.wav` |
| **💝 San Valentín** | Febrero (`2`) | `Dancing Script` / `Poppins` | Rosa Pasión (`#FF2E93`), Rojo Carmín (`#D80032`), Oro Rosa (`#FFB6C1`) | Corazón Voluntario (`Icons.volunteer_activism`) | `assets/audio/valentines.wav` |
| **📱 Normal** | Resto del año | `Inter` (TikTok Clásico) | Rojo TikTok (`#FE2C55`), Cian Eléctrico (`#25F4EE`), Negro Puro (`#000000`) | Corazón Clásico (`Icons.favorite`), Nota Musical | `assets/audio/normal.wav` |

- **Detección Automática:** Al iniciar, `SeasonProvider` consulta la fecha actual del sistema con `DateTime.now().month`.
- **Mecanismo de Prueba Persistente:** Se incluye el botón de temporada en el `TopNavigationBar` que despliega `SeasonSelectorDialog`. Permite al usuario forzar cualquier temporada para evaluación; la selección se guarda en `SharedPreferences` y perdura al reiniciar la aplicación, pudiendo restaurarse a modo automático en cualquier momento.

### B. Secciones Discover / For You / Favorites con Desplazamiento Lateral

- **Estructura en `PageView` Horizontal:** En `MainScreen`, la raíz dispone de un `PageView` horizontal que permite deslizar a la izquierda o derecha entre:
  - **Discover (Página 0):** Exploración de videos de múltiples fuentes (YouTube, Vimeo y Dailymotion) con barra superior de filtros interactivos (`Todos`, `YouTube`, `Vimeo`, `Dailymotion`).
  - **For You / Para ti (Página 1):** Feed principal con la mezcla optimizada de videos locales en assets y transmisiones en red.
  - **Favorites / Favoritos (Página 2):** Colección personalizada de videos guardados por el usuario, respaldados en `SharedPreferences`.
- **Desplazamiento Vertical Interno:** Cada una de las 3 secciones contiene su propio `PageView.builder(scrollDirection: Axis.vertical)` para navegar video por video de forma independiente.

### C. Muteado y Activación de Sonido Dinámico

- Ubicado en la columna de acciones de la esquina inferior derecha (`VideoSideActions`).
- Dispone del icono interactivo de volumen (`Icons.volume_up` cuando el sonido está activo y `Icons.volume_off` en rojo cuando está silenciado).
- Al pulsar, `VideoFeedProvider.toggleMute()` conmuta el estado global y ajusta el volumen del controlador activo (`controller.setVolume(0.0)` vs `controller.setVolume(1.0)` y `youtubeController.mute()` vs `youtubeController.unMute()`).

### D. Persistencia de Me Gustas (+1 / -1) en Local Storage

- Al tocar el botón de Me Gusta:
  - Si el video **no** tenía like: se incrementa el contador (+1), `isLiked = true`, y se guarda tanto el nuevo contador como el flag en `SharedPreferences` (`likes_{videoId}` y `liked_{videoId}`).
  - Si el video **ya** tenía like y se desmarca: se resta un me gusta (-1), `isLiked = false`, y se persiste en almacenamiento local.
- Los datos son persistentes entre sesiones y reinicios de la aplicación mientras no se borre la memoria caché del dispositivo.

### E. Descripción Extensa con "... más" y Desplazamiento Vertical

- En `VideoDescriptionWidget`, si la descripción del video supera el umbral de caracteres (> 80 caracteres), se muestra recortada con el botón interactivo **más**.
- Al presionar **más**, la descripción se expande dentro de un contenedor acotado con `Scrollbar` y `SingleChildScrollView(scrollDirection: Axis.vertical)`.
- Esto permite al usuario deslizar verticalmente el texto largo de la descripción sin interferir con el gesto de cambio de video del `PageView` principal. Al terminar, puede presionar **Ocultar** para regresar a la vista compacta.

### F. Consumo de 3 DataSources Diferentes

El proyecto implementa 3 fuentes de datos independientes desacopladas bajo la arquitectura Clean Code:

1. **`LocalVideoDatasourceImpl`:** Carga los videos MP4 locales ubicados en `assets/videos/`, incluyendo los 2 videos virales descargados por el usuario de `@MrKolinz` (`mrkolinz_1.mp4`: *"Pero de que me tengo que cuidar o que 👀👀"* y `mrkolinz_2.mp4`: *"QUE LE ANDAS AGARRANDO AL CHENTE, KIKO 😭😭"*), junto a los videos demostrativos de desarrollo, totalizando ~28 MB de assets (muy por debajo del límite de 100 MB para commits).
2. **`YouTubeVideoDatasourceImpl`:** Consume videos de YouTube reales vía `YoutubePlayerController` (videos oficiales de Google, Flutter y el primer video histórico de YouTube).
3. **`OnlineStreamDatasourceImpl`:** Consume videos en streaming MP4 de alta velocidad (Vimeo y Dailymotion / Cloud Buckets) para reproducción fluida en red.
4. **`StorageService`:** Abstracción unificada de `SharedPreferences` para la persistencia de likes, favoritos y temporadas.

---

## 4. Diagramas de Arquitectura en GitHub Pages

Los dos diagramas interactivos se elaboraron con **Archify** y se consultan en **GitHub Pages**:

- [Diagrama 1. Arquitectura local](https://angeljdev.github.io/10A-DMI/practica04/arquitectura/local.html): pantallas, videos, temporadas y datos guardados en el dispositivo.
- [Diagrama 2. Appetize y GitHub Pages](https://angeljdev.github.io/10A-DMI/practica04/arquitectura/appetize.html): ejecución del APK en el emulador remoto y publicación de la documentación.

[Abrir la portada de arquitectura de TikiTiki](https://angeljdev.github.io/10A-DMI/practica04/)

---

## 5. Estructura de Directorios del Proyecto

```text
tikitiki/
├── assets/
│   ├── audio/
│   │   ├── christmas.wav        # Chime estacional navideño
│   │   ├── halloween.wav        # Tono sintético misterioso
│   │   ├── normal.wav           # Pop característico estándar
│   │   └── valentines.wav       # Acorde armónico dulce
│   ├── images/
│   │   └── logo.png             # Logotipo de la app
│   └── videos/
│       ├── video_1.mp4          # Video local 1
│       ├── video_2.mp4          # Video local 2
│       ├── video_3.mp4          # Video local 3
│       ├── video_4.mp4          # Video local 4
│       └── video_5.mp4          # Video local 5
├── lib/
│   ├── config/
│   │   └── app_theme.dart       # Configuración global del tema
│   ├── core/
│   │   ├── theme/
│   │   │   └── season_theme.dart    # Enums y configuraciones por temporada
│   │   └── utils/
│   │       ├── number_formats.dart  # Formateo de números (1.2K, 3.5M)
│   │       └── storage_service.dart # SharedPreferences para Likes y Temporada
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local_video_datasource.dart     # DS 1: Videos locales
│   │   │   ├── youtube_video_datasource.dart   # DS 2: YouTube Videos
│   │   │   └── online_stream_datasource.dart   # DS 3: Vimeo / Dailymotion
│   │   ├── mappers/
│   │   │   └── video_mapper.dart               # Mapeo Model -> Entity
│   │   ├── models/
│   │   │   └── video_model.dart                # Modelo de datos serializable
│   │   └── repositories/
│   │       └── video_repository_impl.dart      # Implementación del repositorio
│   ├── domain/
│   │   ├── entities/
│   │   │   └── video.dart                      # Entidad pura con aserciones
│   │   ├── repositories/
│   │   │   └── video_repository.dart           # Contrato abstracto
│   │   └── usecases/
│   │       └── get_videos.dart                 # Caso de uso GetVideos
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── season_provider.dart            # Provider de temporada y audio
│   │   │   └── video_feed_provider.dart        # Provider de videos y mute
│   │   ├── screens/
│   │   │   ├── discover/
│   │   │   │   └── discover_screen.dart        # Sección Discover con filtros
│   │   │   ├── favorites/
│   │   │   │   └── favorites_screen.dart       # Sección Favoritos
│   │   │   └── video_feed_screen.dart          # Sección For You
│   │   └── widgets/
│   │       ├── bottom_navigation_bar_widget.dart # Barra inferior TikTok
│   │       ├── season_selector_dialog.dart       # Modal de prueba de temporadas
│   │       ├── top_navigation_bar.dart           # Pestañas y selector superior
│   │       ├── unified_video_player.dart         # Player local, red y YouTube
│   │       ├── video_description_widget.dart     # Descripción con scroll vertical
│   │       ├── video_player_item.dart            # Stack de video completo
│   │       └── video_side_actions.dart           # Botones laterales y mute
│   └── main.dart                               # Punto de entrada MultiProvider
├── test/
│   ├── core/utils/
│   │   └── number_formats_test.dart            # Pruebas unitarias de formato
│   └── widget_test.dart                        # Pruebas de widget
└── pubspec.yaml                                # Dependencias y configuración
```

---

## 6. Verificación y Pruebas Automatizadas

Se realizaron pruebas automatizadas unitarias y de análisis estático con el SDK de Flutter:

```bash
# Análisis estático de código sin errores
flutter analyze

# Ejecución de pruebas unitarias
flutter test
```

Resultado obtenido:
- **`flutter analyze`:** `0 issues found.`
- **`flutter test`:** `All tests passed! (6/6 pruebas unitarias exitosas)`

---

## 7. Instrucciones para Ejecutar la Aplicación

1. Clonar el repositorio y situarse en la rama `practica04`:
   ```bash
   git checkout practica04
   ```
2. Navegar a la carpeta del proyecto:
   ```bash
   cd docs/practica04/tikitiki
   ```
3. Descargar las dependencias:
   ```bash
   flutter pub get
   ```
4. Ejecutar en emulador o dispositivo físico Android/iOS/Web:
   ```bash
   flutter run
   ```
