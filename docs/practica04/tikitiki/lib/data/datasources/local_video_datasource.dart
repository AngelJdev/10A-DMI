import '../models/video_model.dart';

abstract class LocalVideoDatasource {
  Future<List<VideoModel>> getVideos();
}

class LocalVideoDatasourceImpl implements LocalVideoDatasource {
  @override
  Future<List<VideoModel>> getVideos() async {
    // Simulación de lectura asíncrona de almacenamiento local
    await Future.delayed(const Duration(milliseconds: 300));

    final rawData = [
      {
        // Identificador estable y propio: no hereda likes de otros videos ni
        // se reinicia al abrir la app. Permite capturar 0 -> 1 -> reabrir con 1.
        'id': 'demo_persistencia_likes',
        'url': 'assets/videos/video_1.mp4',
        'usuario': '@tikitiki_demo',
        'descripcion':
            'Mi primer video en TikiTiki. Un corazón para compartir este momento. '
            '#TikiTiki #SanValentin',
        'cancion': 'Sonido original - TikiTiki',
        'likes': 0,
        'comentarios': 0,
        'compartidos': 0,
      },
      {
        'id': 'mrkolinz_video_1',
        'url': 'assets/videos/mrkolinz_1.mp4',
        'usuario': '@MrKolinz',
        'descripcion':
            'Pero de que me tengo que cuidar o que 👀👀 - MrKolinz. Momento viral y comedia clásica en TikTok. Esta descripción es intencionalmente extensa para probar la funcionalidad de (... más) y el desplazamiento vertical interno exclusivo del texto sin interrumpir el deslizamiento del video principal. #MrKolinz #Comedia #Humor #TikTokViral #Risas',
        'cancion': 'Sonido Original - MrKolinz',
        // Video demostrativo: inicia en 0 para comprobar el like persistente.
        'likes': 0,
        'comentarios': 3410,
        'compartidos': 2150,
      },
      {
        'id': 'mrkolinz_video_2',
        'url': 'assets/videos/mrkolinz_2.mp4',
        'usuario': '@MrKolinz',
        'descripcion':
            'QUE LE ANDAS AGARRANDO AL CHENTE, KIKO 😭😭 - MrKolinz. Parodia y comedia mexicana con Don Chente y Kiko. #MrKolinz #HumorMexicano #Chente #Kiko #Comedia #Viral',
        'cancion': 'Audio Original - MrKolinz Comedy',
        'likes': 124300,
        'comentarios': 6890,
        'compartidos': 4520,
      },
      {
        'id': 'local_video_1',
        'url': 'assets/videos/video_1.mp4',
        'usuario': '@angel_flutter',
        'descripcion':
            'Explorando las novedades de Flutter 3 y Material 3 con Clean Architecture y Providers reactivos en una interfaz estilo TikTok súper fluida! #FlutterDev #CleanCode #MobileDev #Dart #OpenSource',
        'cancion': 'Sonido original - Angel Baños',
        'likes': 14200,
        'comentarios': 450,
        'compartidos': 180,
      },
      {
        'id': 'local_video_2',
        'url': 'assets/videos/video_2.mp4',
        'usuario': '@dmi_dev10a',
        'descripcion':
            'Desarrollo Móvil Integral: Práctica 4 TikTok Clone con soporte multidispositivo, gestión dinámica de temas por temporada (Halloween, Navidad, San Valentín y Normal), scroll vertical y horizontal con arquitectura CLEAN. #UPP #Universidad #TikTokClone #CodeLife',
        'cancion': 'Cyberpunk Chill Vibes - DMI Beats',
        'likes': 28900,
        'comentarios': 1230,
        'compartidos': 940,
      },
      {
        'id': 'local_video_3',
        'url': 'assets/videos/video_3.mp4',
        'usuario': '@clean_coder',
        'descripcion':
            'Buenas prácticas de Clean Code en Dart: separación estricta en capas Domain, Data, Core y Presentation. Desacoplamiento total entre fuentes de datos y widgets de la interfaz visual.',
        'cancion': 'Synthwave Coding Session - LoFi Girl',
        'likes': 9800,
        'comentarios': 310,
        'compartidos': 140,
      },
      {
        'id': 'local_video_4',
        'url': 'assets/videos/video_4.mp4',
        'usuario': '@pixel_art',
        'descripcion':
            'Animaciones fluidas y microinteracciones de botón me gusta con gradientes personalizados por estación del año. ¿Cuál es tu temporada favorita?',
        'cancion': 'Retro Wave - 8-Bit Chill',
        'likes': 7300,
        'comentarios': 190,
        'compartidos': 85,
      },
      {
        'id': 'local_video_5',
        'url': 'assets/videos/video_5.mp4',
        'usuario': '@flutter_master',
        'descripcion':
            'Demostración de controladores de video en bucle con detección de gestos: doble tap para corazón instantáneo, un tap para pausa y toggle de audio dinámico en la columna de acciones. #TikTok #DartTips #MobileMastery',
        'cancion': 'Future Bass Energy - Flutter Sound',
        'likes': 34500,
        'comentarios': 2400,
        'compartidos': 1600,
      },
    ];

    // Uso de Loop para construcción de modelos a partir de raw data
    final List<VideoModel> videos = [];
    for (final item in rawData) {
      videos.add(
        VideoModel(
          id: item['id'] as String,
          url: item['url'] as String,
          usuario: item['usuario'] as String,
          descripcion: item['descripcion'] as String,
          cancion: item['cancion'] as String,
          likes: item['likes'] as int,
          comentarios: item['comentarios'] as int,
          compartidos: item['compartidos'] as int,
          source: 'local',
        ),
      );
    }

    return videos;
  }
}
