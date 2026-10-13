enum VideoSource { youtube, tiktok, reels }

class Recommendation {
  final String id;
  final VideoSource source;
  final String title;
  final String author;
  final String thumbnailUrl;
  final String videoUrl;      // URL directa al video (MP4) o videoId de YouTube
  final String? linkUrl;      // URL original (para YouTube: watch URL, TikTok/Reels: perfil)

  Recommendation({
    required this.id,
    required this.source,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.linkUrl,
  });

  /// Para YouTube: devuelve el videoId extraído de videoUrl o linkUrl
  String? get youtubeVideoId {
    if (source != VideoSource.youtube) return null;
    // videoUrl puede ser el ID directo o la URL completa
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      final uri = Uri.parse(videoUrl);
      if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
      return uri.queryParameters['v'];
    }
    return videoUrl; // Asumimos que ya es el ID
  }
}