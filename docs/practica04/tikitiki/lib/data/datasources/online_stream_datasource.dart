import '../models/video_model.dart';

abstract class OnlineStreamDatasource {
  Future<List<VideoModel>> getVideos();
}

class OnlineStreamDatasourceImpl implements OnlineStreamDatasource {
  @override
  Future<List<VideoModel>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 350));

    // Videos MP4 públicos de Archive.org (sin restricción CORS ni referrer)
    // Seleccionados por ser ligeros y de acceso libre desde emuladores Android
    final List<Map<String, dynamic>> streamClips = [
      {
        'id': 'stream_archive_1',
        'url':
            'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4',
        'usuario': '@nature_hd',
        'descripcion':
            'Big Buck Bunny — cortometraje animado de Blender Foundation. '
            'Ejemplo de animación 3D de alta calidad renderizada con software libre. '
            '#Animation #OpenSource #Blender #3D #Nature',
        'cancion': 'Big Buck Bunny OST - Jan Morgenstern',
        'likes': 65400,
        'comentarios': 3890,
        'compartidos': 2450,
        'source': 'archive',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
      },
      {
        'id': 'stream_archive_2',
        'url':
            'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4',
        'usuario': '@blender_studio',
        'descripcion':
            'Elephants Dream — primera producción open-movie de Blender. '
            'Vanguardia del cine digital creado con herramientas de software libre. '
            '#Blender #OpenMovie #CGI #DigitalArt',
        'cancion': 'Elephants Dream OST - Jan Morgenstern',
        'likes': 48300,
        'comentarios': 2100,
        'compartidos': 1300,
        'source': 'archive',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
      },
      {
        'id': 'stream_archive_3',
        'url':
            'https://archive.org/download/Popeye_forPresident/Popeye_forPresident_512kb.mp4',
        'usuario': '@classic_cartoons',
        'descripcion':
            'Popeye for President — dibujo animado clásico de 1956 del dominio público. '
            'Parte del patrimonio cultural de la animación americana. '
            '#Classic #Cartoon #PublicDomain #RetroAnimation',
        'cancion': 'Popeye Theme - Classic',
        'likes': 77100,
        'comentarios': 4620,
        'compartidos': 3100,
        'source': 'archive',
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
