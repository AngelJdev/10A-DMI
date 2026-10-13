import '../../domain/entities/recommendation.dart';

class ReelsDemoDatasource {
  // Videos MP4 públicos de prueba para reproducción inline
  static const List<String> demoMp4Urls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  Future<List<Recommendation>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Recommendation(
        id: 'reel_1',
        source: VideoSource.reels,
        title: 'Atardecer increíble en la playa 🌅',
        author: '@viajes_pro',
        thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
        videoUrl: demoMp4Urls[0],
        linkUrl: 'https://www.instagram.com/reels/',
      ),
      Recommendation(
        id: 'reel_2',
        source: VideoSource.reels,
        title: 'Receta rápida de pasta cremosa 🍝',
        author: '@chef_en_casa',
        thumbnailUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500',
        videoUrl: demoMp4Urls[1],
        linkUrl: 'https://www.instagram.com/reels/',
      ),
      Recommendation(
        id: 'reel_3',
        source: VideoSource.reels,
        title: 'Rutina de ejercicio matutino 💪',
        author: '@fitness_life',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
        videoUrl: demoMp4Urls[2],
        linkUrl: 'https://www.instagram.com/reels/',
      ),
    ];
  }
}