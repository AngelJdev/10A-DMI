import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/recommendation.dart';

class TikTokOembedDatasource {
  // URLs de TikTok de ejemplo para obtener metadata via oEmbed
  static const List<String> sampleUrls = [
    'https://www.tiktok.com/@scout2015/video/6718335390845095173',
    'https://www.tiktok.com/@ox_zung/video/7036798902099307782',
  ];

  // Videos MP4 públicos de prueba (sample videos) para reproducción inline
  static const List<String> demoMp4Urls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ];

  Future<List<Recommendation>> getVideos() async {
    final List<Recommendation> results = [];

    for (int i = 0; i < sampleUrls.length; i++) {
      final url = sampleUrls[i];
      try {
        final response = await http.get(
          Uri.parse('https://www.tiktok.com/oembed?url=$url'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          results.add(
            Recommendation(
              id: 'tiktok_$i',
              source: VideoSource.tiktok,
              title: data['title'] ?? 'Video viral de TikTok',
              author: data['author_name'] ?? 'Creador de TikTok',
              thumbnailUrl: data['thumbnail_url'] ?? _fallbackThumbnail(i),
              videoUrl: demoMp4Urls[i], // MP4 demo para reproducción inline
              linkUrl: url,
            ),
          );
        }
      } catch (_) {
        // Ignorar error individual
      }
    }

    if (results.isEmpty) {
      results.addAll(_fallbackDemo());
    }

    return results;
  }

  List<Recommendation> _fallbackDemo() {
    return [
      Recommendation(
        id: 'tiktok_demo_1',
        source: VideoSource.tiktok,
        title: 'Baile viral tendencia #TikiTiki',
        author: '@carlos_dance',
        thumbnailUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500',
        videoUrl: demoMp4Urls[0],
        linkUrl: 'https://www.tiktok.com',
      ),
      Recommendation(
        id: 'tiktok_demo_2',
        source: VideoSource.tiktok,
        title: 'Trucos de programación en 1 min',
        author: '@dev_tips',
        thumbnailUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500',
        videoUrl: demoMp4Urls[1],
        linkUrl: 'https://www.tiktok.com',
      ),
    ];
  }

  String _fallbackThumbnail(int index) {
    const thumbs = [
      'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500',
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500',
    ];
    return thumbs[index % thumbs.length];
  }
}