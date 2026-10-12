import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/youtube_rss_datasource.dart';
import '../datasources/tiktok_oembed_datasource.dart';
import '../datasources/reels_demo_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final YouTubeRssDatasource youtubeDatasource;
  final TikTokOembedDatasource tiktokDatasource;
  final ReelsDemoDatasource reelsDatasource;

  RecommendationRepositoryImpl({
    required this.youtubeDatasource,
    required this.tiktokDatasource,
    required this.reelsDatasource,
  });

  @override
  Future<List<Recommendation>> getRecommendations(VideoSource source) async {
    switch (source) {
      case VideoSource.youtube:
        return await youtubeDatasource.getVideos();
      case VideoSource.tiktok:
        return await tiktokDatasource.getVideos();
      case VideoSource.reels:
        return await reelsDatasource.getVideos();
    }
  }
}
