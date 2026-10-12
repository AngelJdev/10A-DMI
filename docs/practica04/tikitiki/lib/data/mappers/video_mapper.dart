import '../../domain/entities/video.dart';
import '../models/video_model.dart';

class VideoMapper {
  static Video videoModelToEntity(
    VideoModel model, {
    int? customLikes,
    bool isLiked = false,
    bool isFavorite = false,
  }) {
    VideoSource source;
    switch (model.source.toLowerCase()) {
      case 'youtube':
        source = VideoSource.youtube;
        break;
      case 'dailymotion':
        source = VideoSource.dailymotion;
        break;
      case 'vimeo':
        source = VideoSource.vimeo;
        break;
      default:
        source = VideoSource.local;
    }

    return Video(
      id: model.id,
      url: model.url,
      usuario: model.usuario,
      descripcion: model.descripcion,
      cancion: model.cancion,
      likes: customLikes ?? model.likes,
      comentarios: model.comentarios,
      compartidos: model.compartidos,
      source: source,
      thumbnailUrl: model.thumbnailUrl,
      isLiked: isLiked,
      isFavorite: isFavorite,
    );
  }
}
