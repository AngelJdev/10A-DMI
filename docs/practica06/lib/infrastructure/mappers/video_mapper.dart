import '../../domain/entities/video.dart';
import '../models/moviedb/moviedb_video.dart';

class VideoMapper {
  static Video toEntity(MoviedbVideo video) => Video(
    id: video.id,
    name: video.name,
    youtubeKey: video.key,
    publishedAt: video.publishedAt,
    language: video.language,
    type: video.type,
    official: video.official,
  );
}
