import '../../domain/entities/movie.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../../domain/datasources/local_storage_datasource.dart';
import '../database/movies_database.dart';
import '../datasources/drift_datasource.dart';

class DriftStorageRepository implements LocalStorageRepository {
  DriftStorageRepository(MoviesDatabase database)
    : datasource = DriftDatasource(database);
  final LocalStorageDatasource datasource;

  @override
  Future<bool> isFavorite(int movieId, {MediaType type = MediaType.movie}) =>
      datasource.isFavorite(movieId, type: type);
  @override
  Future<void> toggleFavorite(Movie movie) => datasource.toggleFavorite(movie);
  @override
  Future<List<Movie>> loadMovies({
    int offset = 0,
    int limit = 20,
    MediaType? type,
  }) => datasource.loadMovies(offset: offset, limit: limit, type: type);
}
