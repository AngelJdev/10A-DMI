import '../../domain/entities/movie.dart';
import '../models/moviedb/movie_moviedb.dart';
import 'movie_mapper.dart';

class SeriesMapper {
  static Movie toEntity(Map<String, dynamic> json) {
    final base = MovieMapper.movieDBToEntity(
      MovieDb.fromJson({
        ...json,
        'title': json['name'],
        'original_title': json['original_name'],
        'release_date': json['first_air_date'],
      }),
    );
    final genres = json['genres'];
    return Movie.fromJson({
      ...base.toJson(),
      'mediaType': 'series',
      'seasons': json['number_of_seasons'],
      'episodes': json['number_of_episodes'],
      if (genres is List)
        'genreIds': genres
            .whereType<Map<String, dynamic>>()
            .map((genre) => genre['name'])
            .whereType<String>()
            .toList(),
    });
  }
}
