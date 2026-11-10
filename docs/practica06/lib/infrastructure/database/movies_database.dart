import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'movies_database.g.dart';

class FavoriteEntries extends Table {
  IntColumn get movieId => integer()();
  TextColumn get mediaType => text().withDefault(const Constant('movie'))();
  TextColumn get payload => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {movieId, mediaType};
}

@DriftDatabase(tables: [FavoriteEntries])
class MoviesDatabase extends _$MoviesDatabase {
  MoviesDatabase(super.executor);
  MoviesDatabase.open() : super(driftDatabase(name: 'cinemapedia'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await transaction(() async {
          await m.alterTable(
            TableMigration(
              favoriteEntries,
              newColumns: [favoriteEntries.mediaType],
            ),
          );
        });
      }
    },
  );
}
