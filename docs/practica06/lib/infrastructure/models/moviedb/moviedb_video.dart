class MoviedbVideo {
  const MoviedbVideo({
    required this.id,
    required this.name,
    required this.key,
    required this.site,
    required this.publishedAt,
    required this.language,
    required this.type,
    required this.official,
  });
  final String id, name, key, site, language, type;
  final DateTime? publishedAt;
  final bool official;

  factory MoviedbVideo.fromJson(Map<String, dynamic> json) => MoviedbVideo(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    key: json['key'] as String? ?? '',
    site: json['site'] as String? ?? '',
    publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    language: json['iso_639_1'] as String? ?? '',
    type: json['type'] as String? ?? '',
    official: json['official'] == true,
  );
}
