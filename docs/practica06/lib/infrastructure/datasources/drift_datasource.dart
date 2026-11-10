import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/movie.dart';
import '../../domain/datasources/local_storage_datasource.dart';
import '../database/movies_database.dart';

class DriftDatasource implements LocalStorageDatasource {
  DriftDatasource(this.database);
  final MoviesDatabase database;

  @override
  Future<bool> isFavorite(
    int movieId, {
    MediaType type = MediaType.movie,
  }) async =>
      await (database.select(database.favoriteEntries)..where(
            (row) =>
                row.movieId.equals(movieId) & row.mediaType.equals(type.name),
          ))
          .getSingleOrNull() !=
      null;

  @override
  Future<void> toggleFavorite(Movie movie) => database.transaction(() async {
    if (await isFavorite(movie.id, type: movie.mediaType)) {
      await (database.delete(database.favoriteEntries)..where(
            (row) =>
                row.movieId.equals(movie.id) &
                row.mediaType.equals(movie.mediaType.name),
          ))
          .go();
    } else {
      await database
          .into(database.favoriteEntries)
          .insert(
            FavoriteEntriesCompanion.insert(
              movieId: movie.id,
              mediaType: Value(movie.mediaType.name),
              payload: jsonEncode(movie.toJson()),
              savedAt: DateTime.now(),
            ),
          );
    }
  });

  @override
  Future<List<Movie>> loadMovies({
    int offset = 0,
    int limit = 20,
    MediaType? type,
  }) async {
    final rows =
        await (database.select(database.favoriteEntries)
              ..where(
                (row) => type == null
                    ? const Constant(true)
                    : row.mediaType.equals(type.name),
              )
              ..orderBy([
                (row) => OrderingTerm.desc(row.savedAt),
                (row) => OrderingTerm.desc(row.movieId),
                (row) => OrderingTerm.desc(row.mediaType),
              ])
              ..limit(limit, offset: offset))
            .get();
    return rows
        .map(
          (row) =>
              Movie.fromJson(jsonDecode(row.payload) as Map<String, dynamic>),
        )
        .toList();
  }
}
