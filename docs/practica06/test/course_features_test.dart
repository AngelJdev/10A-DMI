import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practica06/infrastructure/database/movies_database.dart';
import 'package:practica06/infrastructure/repositories/drift_storage_repository.dart';
import 'package:practica06/infrastructure/mappers/movie_mapper.dart';
import 'package:practica06/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/presentation/providers/providers.dart';

Movie movie(int id) => MovieMapper.movieDBToEntity(
  MovieDb.fromJson({
    'id': id,
    'title': 'Película $id',
    'poster_path': '/$id.jpg',
    'release_date': '2026-10-01',
    'vote_average': 8.3,
  }),
);

void main() {
  test(
    'Favoritos sobreviven al cierre de SQLite y se paginan sin duplicados',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cinemapedia-test-',
      );
      final file = File('${directory.path}/favorites.sqlite');
      var database = MoviesDatabase(NativeDatabase(file));
      var storage = DriftStorageRepository(database);
      try {
        for (var id = 1; id <= 25; id++) {
          await storage.toggleFavorite(movie(id));
        }
        await database.close();
        database = MoviesDatabase(NativeDatabase(file));
        storage = DriftStorageRepository(database);
        final first = await storage.loadMovies();
        final second = await storage.loadMovies(offset: 20);
        expect(first.length, 20);
        expect(second.length, 5);
        expect(
          {...first.map((m) => m.id), ...second.map((m) => m.id)}.length,
          25,
        );
        expect(await storage.isFavorite(1), isTrue);
        expect(second.last.title, 'Película 1');
        expect(second.last.releaseDate, DateTime(2026, 10, 1));
        await storage.toggleFavorite(movie(1));
        expect(await storage.isFavorite(1), isFalse);
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'Paginación bloquea llamadas simultáneas y termina al recibir página vacía',
    () async {
      var calls = 0;
      final response = Completer<List<Movie>>();
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) {
          calls++;
          return page == 1 ? response.future : Future.value([]);
        },
      );
      addTearDown(notifier.dispose);
      final first = notifier.loadNextPage();
      await notifier.loadNextPage();
      expect(calls, 1);
      response.complete([movie(1), movie(1)]);
      await first;
      expect(notifier.currentPage, 1);
      await notifier.loadNextPage();
      await notifier.loadNextPage();
      expect(calls, 2);
      expect(notifier.hasMore, isFalse);
    },
  );

  test(
    'Una página fallida se puede reintentar sin saltar el número de página',
    () async {
      var fail = true;
      final pages = <int>[];
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          pages.add(page);
          if (fail) throw StateError('Sin conexión');
          return [movie(1)];
        },
      );
      addTearDown(notifier.dispose);
      await expectLater(notifier.loadNextPage(), throwsStateError);
      fail = false;
      await notifier.loadNextPage();
      expect(pages, [1, 1]);
      expect(notifier.currentPage, 1);
    },
  );

  test('El provider de favoritos actualiza SQLite y consulta IDs fuera de la primera página', () async {
    final database = MoviesDatabase(NativeDatabase.memory());
    final storage = DriftStorageRepository(database);
    for (var id = 1; id <= 25; id++) {
      await storage.toggleFavorite(movie(id));
    }
    final container = ProviderContainer(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    try {
      expect((await container.read(favoriteMoviesProvider.future)).length, 20);
      expect(await container.read(isFavoriteProvider(1).future), isTrue);
      await container.read(favoriteMoviesProvider.notifier).loadNextPage();
      expect(container.read(favoriteMoviesProvider).value!.length, 25);
      await container.read(favoriteMoviesProvider.notifier).toggle(movie(1));
      expect(await storage.isFavorite(1), isFalse);
      expect(container.read(favoriteMoviesProvider).value!.length, 24);
    } finally {
      container.dispose();
      await database.close();
    }
  });
}
