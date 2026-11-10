import 'movie_moviedb.dart';

class MovieDetails {
  const MovieDetails({required this.movie, required this.genres});
  final MovieDb movie;
  final List<String> genres;

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final raw = json['genres'];
    return MovieDetails(
      movie: MovieDb.fromJson(json),
      genres: raw is List
          ? raw
                .whereType<Map<String, dynamic>>()
                .map((genre) => genre['name'])
                .whereType<String>()
                .toList()
          : const [],
    );
  }
}
