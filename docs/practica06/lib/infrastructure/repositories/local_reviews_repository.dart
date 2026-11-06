import 'dart:convert';

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
  Future<List<LocalReview>> load(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('movie_reviews_v1_$movieId') ?? [])
        .map(LocalReview.decode)
        .toList();
  }

  Future<void> save(int movieId, List<LocalReview> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setStringList(
      'movie_reviews_v1_$movieId',
      reviews.map((r) => r.encode()).toList(),
    );
    if (!saved) throw StateError('No se pudo guardar la reseña');
  }
}
