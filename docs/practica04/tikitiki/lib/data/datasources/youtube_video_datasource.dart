import '../models/video_model.dart';

abstract class YouTubeVideoDatasource {
  Future<List<VideoModel>> getVideos();
}

class YouTubeVideoDatasourceImpl implements YouTubeVideoDatasource {
  @override
  Future<List<VideoModel>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Videos en streaming directo sin interfaces web de terceros (solo el video limpio)
    final List<Map<String, dynamic>> onlineClips = [
      {
        'id': 'yt_vid_1',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'usuario': '@google_developers',
        'descripcion':
            'Novedades de Inteligencia Artificial y Flutter: renderizado nativo a 60 FPS con Clean Architecture. #GoogleIO #Flutter #Dart #CleanCode',
        'cancion': 'Google Developers Audio - Tech Pulse',
        'likes': 158000,
        'comentarios': 4500,
        'compartidos': 3200,
        'source': 'youtube',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
      },
      {
        'id': 'yt_vid_2',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'usuario': '@flutter_devs',
        'descripcion':
            'Construcción de interfaces fluidas estilo TikTok en dispositivos móviles: State Management con Providers y consumo de múltiples datasources. #FlutterDev #Mobile #CodeLife',
        'cancion': 'LoFi Coding Beats - Chill Wave',
        'likes': 89200,
        'comentarios': 740,
        'compartidos': 510,
        'source': 'youtube',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
      },
      {
        'id': 'yt_vid_3',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'usuario': '@tech_creators',
        'descripcion':
            'Clean Code en aplicaciones móviles: separación estricta de capas Domain, Data y Presentation para desacoplamiento total. #CleanCode #DartLang #SoftwareArchitecture',
        'cancion': 'Synthwave Chill - Retro Future',
        'likes': 42100,
        'comentarios': 280,
        'compartidos': 190,
        'source': 'youtube',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500',
      },
      {
        'id': 'yt_vid_4',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        'usuario': '@creative_code',
        'descripcion':
            'Microinteracciones y gradientes dinámicos adaptados a la temporada del año (Halloween, Día de Muertos, Navidad y San Valentín). #UIDesign #CreativeDev',
        'cancion': 'Cyber Beats 2026 - Digital Energy',
        'likes': 67500,
        'comentarios': 920,
        'compartidos': 430,
        'source': 'youtube',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500',
      },
    ];

    final List<VideoModel> results = [];
    for (int i = 0; i < onlineClips.length; i++) {
      results.add(VideoModel.fromJson(onlineClips[i]));
    }
    return results;
  }
}
