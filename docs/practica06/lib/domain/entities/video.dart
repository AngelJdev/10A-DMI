class Video {
  const Video({
    required this.id,
    required this.name,
    required this.youtubeKey,
    required this.publishedAt,
    required this.language,
    required this.type,
    required this.official,
  });
  final String id;
  final String name;
  final String youtubeKey;
  final DateTime? publishedAt;
  final String language;
  final String type;
  final bool official;
}
