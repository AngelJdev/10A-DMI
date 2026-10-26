import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:practica06/infrastructure/models/moviedb/moviedb_response.dart';

void main() {
  group('MovieDb.fromJson', () {
    test('converts API values and parses the release date', () {
      final movie = MovieDb.fromJson({
        'adult': false,
        'backdrop_path': '/backdrop.jpg',
        'genre_ids': [28, 12.0, 'invalid'],
        'id': 42.0,
        'original_language': 'en',
        'original_title': 'Example',
        'overview': 'Description',
        'popularity': 12,
        'poster_path': '/poster.jpg',
        'release_date': '2024-02-03',
        'title': 'Example',
        'video': false,
        'vote_average': 8,
        'vote_count': 120,
      });

      expect(movie.genreIds, [28, 12]);
      expect(movie.id, 42);
      expect(movie.popularity, 12.0);
      expect(movie.releaseDate, DateTime(2024, 2, 3));
      expect(movie.voteAverage, 8.0);
    });

    test('keeps optional image paths and invalid dates null', () {
      final movie = MovieDb.fromJson({
        'backdrop_path': null,
        'poster_path': null,
        'release_date': 'invalid-date',
      });

      expect(movie.backdropPath, isNull);
      expect(movie.posterPath, isNull);
      expect(movie.releaseDate, isNull);
    });
  });

  test('parses only map entries from the results list', () {
    final response = MovieDbResponse.fromJson({
      'results': [
        {'id': 1},
        null,
        'invalid',
        {'id': 2},
      ],
    });

    expect(response.results.map((movie) => movie.id), [1, 2]);
  });
}
