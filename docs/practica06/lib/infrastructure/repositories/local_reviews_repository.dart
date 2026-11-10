import 'dart:convert';

import '../../domain/entities/movie.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalReview {
  const LocalReview({
    required this.text,
    required this.stars,
    required this.created,
  });
  final String text;
  final int stars;
  final DateTime created;
  String encode() => jsonEncode({
    'text': text,
    'stars': stars,
    'created': created.toIso8601String(),
  });
  factory LocalReview.decode(String value) {
    final data = jsonDecode(value) as Map<String, dynamic>;
    return LocalReview(
      text: data['text'] as String,
      stars: data['stars'] as int,
      created: DateTime.parse(data['created'] as String),
    );
  }
}

class LocalReviewsRepository {
  String _key(int id, MediaType type) =>
      '${type == MediaType.series ? 'series' : 'movie'}_reviews_v1_$id';

  Future<List<LocalReview>> load(
    int movieId, {
    MediaType type = MediaType.movie,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key(movieId, type)) ?? [])
        .map(LocalReview.decode)
        .toList();
  }

  Future<void> save(
    int movieId,
    List<LocalReview> reviews, {
    MediaType type = MediaType.movie,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setStringList(
      _key(movieId, type),
      reviews.map((r) => r.encode()).toList(),
    );
    if (!saved) throw StateError('No se pudo guardar la reseña');
  }
}
