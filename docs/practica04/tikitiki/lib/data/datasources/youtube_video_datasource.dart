import '../models/video_model.dart';

abstract class YouTubeVideoDatasource {
  Future<List<VideoModel>> getVideos();
}

class YouTubeVideoDatasourceImpl implements YouTubeVideoDatasource {
  @override
  Future<List<VideoModel>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Videos MP4 públicos de Archive.org y Wikimedia Commons (sin CORS/referrer)
    // Se usan como sustituto de YouTube para evitar el 403 desde emulador
    final List<Map<String, dynamic>> onlineClips = [
      {
        'id': 'yt_vid_1',
        'url':
            'https://archive.org/download/Sintel/sintel-2048-surround.mp4',
        'usuario': '@blender_foundation',
        'descripcion':
            'Sintel — cortometraje épico de fantasía producido por Blender Foundation. '
            'Demuestra el poder del renderizado Cycles y la animación procedural. '
            '#Blender #Fantasy #OpenMovie #3DAnimation #FlutterDev',
        'cancion': 'Sintel OST - Jan Morgenstern',
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
            'https://archive.org/download/TearsOfSteel/tears_of_steel_720p.mov',
        'usuario': '@mango_studio',
        'descripcion':
            'Tears of Steel — corto VFX open-source de Blender. '
            'Integración de live action con efectos visuales en tiempo real. '
            '#VFX #Blender #OpenSource #CGI #DigitalCinema',
        'cancion': 'Tears of Steel OST - Joram van Hartingsveldt',
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
            'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4',
        'usuario': '@tech_creators',
        'descripcion':
            'Clean Code en aplicaciones móviles: separación estricta de capas '
            'Domain, Data y Presentation para desacoplamiento total. '
            '#CleanCode #DartLang #SoftwareArchitecture #Flutter',
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
            'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4',
        'usuario': '@creative_code',
        'descripcion':
            'Microinteracciones y gradientes dinámicos adaptados a la temporada del año '
            '(Halloween, Día de Muertos, Navidad y San Valentín). '
            '#UIDesign #CreativeDev #Flutter #SeasonalTheme',
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
