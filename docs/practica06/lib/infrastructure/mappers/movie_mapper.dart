import '../../domain/entities/movie.dart';
import '../models/moviedb/movie_moviedb.dart';
import '../models/moviedb/movie_details.dart';

class MovieMapper {
  static Movie movieDBToEntity(MovieDb moviedb) => _toEntity(moviedb);

  static Movie movieDetailsToEntity(MovieDetails details) =>
      _toEntity(details.movie, genres: details.genres);

  static Movie _toEntity(MovieDb moviedb, {List<String>? genres}) => Movie(
    adult: moviedb.adult,
    backdropPath:
        'https://image.tmdb.org/t/p/w500${moviedb.backdropPath?.isNotEmpty == true ? moviedb.backdropPath : moviedb.posterPath}',
    genreIds: genres ?? moviedb.genreIds.map((id) => id.toString()).toList(),
    id: moviedb.id,
    originalLanguage: moviedb.originalLanguage,
    originalTitle: moviedb.originalTitle,
    overview: moviedb.overview,
    popularity: moviedb.popularity,
    posterPath: 'https://image.tmdb.org/t/p/w500${moviedb.posterPath}',
    releaseDate: moviedb.releaseDate,
    title: moviedb.title,
    video: moviedb.video,
    voteAverage: moviedb.voteAverage,
    voteCount: moviedb.voteCount,
  );
}
