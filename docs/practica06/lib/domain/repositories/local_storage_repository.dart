import '../entities/movie.dart';

abstract class LocalStorageRepository {
  Future<List<Movie>> loadMovies({
    int offset = 0,
    int limit = 20,
    MediaType? type,
  });
  Future<bool> isFavorite(int movieId, {MediaType type = MediaType.movie});
  Future<void> toggleFavorite(Movie movie);
}
