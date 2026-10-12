import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../domain/entities/recommendation.dart';

class YouTubeRssDatasource {
  static const String channelId = 'UC_x5XG1OV2P6uZZ5FSM9Ttw';

  Future<List<Recommendation>> getVideos() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.youtube.com/feeds/videos.xml?channel_id=$channelId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al conectar con YouTube RSS');
      }

      final document = XmlDocument.parse(response.body);
      final entries = document.findAllElements('entry');
      final List<Recommendation> results = [];

      for (var entry in entries) {
        String? videoId;
        for (var el in entry.descendants.whereType<XmlElement>()) {
          if (el.name.local == 'videoId') {
            videoId = el.innerText;
            break;
          }
        }
        
        String title = 'Sin título';
        for (var el in entry.descendants.whereType<XmlElement>()) {
          if (el.name.local == 'title') {
            title = el.innerText;
            break;
          }
        }

        String author = 'Google / YouTube';
        for (var el in entry.descendants.whereType<XmlElement>()) {
          if (el.name.local == 'name') {
            author = el.innerText;
            break;
          }
        }

        if (videoId != null && videoId.isNotEmpty) {
          results.add(
            Recommendation(
              id: videoId,
              source: VideoSource.youtube,
              title: title,
              author: author,
              thumbnailUrl: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
              videoUrl: videoId, // youtube_player_flutter usa el videoId
              linkUrl: 'https://www.youtube.com/watch?v=$videoId',
            ),
          );
        }
      }

      return results;
    } catch (e) {
      return _fallbackDemo();
    }
  }

  List<Recommendation> _fallbackDemo() {
    return [
      Recommendation(
        id: 'yt_demo_1',
        source: VideoSource.youtube,
        title: 'Google I/O Keynote Highlights (Demo)',
        author: 'Google Developers',
        thumbnailUrl: 'https://i.ytimg.com/vi/jNQXAC9IVRw/hqdefault.jpg',
        videoUrl: 'jNQXAC9IVRw',
        linkUrl: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
      ),
      Recommendation(
        id: 'yt_demo_2',
        source: VideoSource.youtube,
        title: 'Flutter & AI Innovations (Demo)',
        author: 'Flutter',
        thumbnailUrl: 'https://i.ytimg.com/vi/VPvVD8t02U8/hqdefault.jpg',
        videoUrl: 'VPvVD8t02U8',
        linkUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
      ),
    ];
  }
}