import 'movie_moviedb.dart';

class MovieDbResponse {
  const MovieDbResponse({required this.results});

  final List<MovieDb> results;

  factory MovieDbResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];

    return MovieDbResponse(
      results: rawResults is List
          ? rawResults
                .whereType<Map>()
                .map((result) => Map<String, dynamic>.from(result))
                .map(MovieDb.fromJson)
                .toList()
          : const [],
    );
  }
}
