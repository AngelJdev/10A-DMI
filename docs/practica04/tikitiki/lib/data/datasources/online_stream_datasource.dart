import '../models/video_model.dart';

abstract class OnlineStreamDatasource {
  Future<List<VideoModel>> getVideos();
}

class OnlineStreamDatasourceImpl implements OnlineStreamDatasource {
  @override
  Future<List<VideoModel>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 350));

    // Videos en streaming MP4 directos de alta disponibilidad (Vimeo / CDN abiertos)
    final List<Map<String, dynamic>> streamClips = [
      {
        'id': 'vimeo_stream_1',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'usuario': '@vimeo_nature',
        'descripcion':
            'Fascinante captura en alta resolución de fuego y naturaleza en movimiento. Grabado con óptica cinematográfica y etalonaje profesional de color HDR para dispositivos móviles. #Nature #VimeoStaffPick #Cinematography #FireAndIce #Landscape',
        'cancion': 'Ambient Fire Symphony - Nature Sounds',
        'likes': 65400,
        'comentarios': 3890,
        'compartidos': 2450,
        'source': 'vimeo',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
      },
      {
        'id': 'dailymotion_stream_2',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'usuario': '@dailymotion_travel',
        'descripcion':
            'Explorando los rincones más impresionantes del mundo. Un viaje visual que desafía los sentidos y nos conecta con los horizontes lejanos de la aventura global. #Travel #Wanderlust #DailymotionTrends #AdventureTime',
        'cancion': 'Acoustic Escape - Wanderer Melodies',
        'likes': 48300,
        'comentarios': 2100,
        'compartidos': 1300,
        'source': 'dailymotion',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
      },
      {
        'id': 'vimeo_stream_3',
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'usuario': '@motion_graphics_lab',
        'descripcion':
            'Diseño interactivo y animación de personajes en 3D: el proceso creativo detrás de las mejores campañas publicitarias audiovisuales de la era digital.',
        'cancion': 'Upbeat Electro Fun - Party Track',
        'likes': 77100,
        'comentarios': 4620,
        'compartidos': 3100,
        'source': 'vimeo',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500',
      },
    ];

    final List<VideoModel> models = [];
    for (final clip in streamClips) {
      models.add(VideoModel.fromJson(clip));
    }
    return models;
  }
}
