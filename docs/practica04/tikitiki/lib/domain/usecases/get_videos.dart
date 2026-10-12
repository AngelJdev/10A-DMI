import '../entities/video.dart';
import '../repositories/video_repository.dart';

enum FeedType { forYou, discover, favorites, liked }

class GetVideos {
  final VideoRepository repository;

  GetVideos(this.repository);

  Future<List<Video>> call({FeedType type = FeedType.forYou}) {
    switch (type) {
      case FeedType.forYou:
        return repository.getForYouVideos();
      case FeedType.discover:
        return repository.getDiscoverVideos();
      case FeedType.favorites:
        return repository.getFavoriteVideos();
      case FeedType.liked:
        return repository.getLikedVideos();
    }
  }
}
