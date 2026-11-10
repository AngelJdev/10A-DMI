import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practica06/app_router.dart';
import 'package:practica06/main.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/infrastructure/database/movies_database.dart';
import 'package:practica06/infrastructure/datasources/moviedb_datasource.dart';
import 'package:practica06/infrastructure/repositories/movie_repository_impl.dart';
import 'package:practica06/infrastructure/repositories/movies_repository_provider.dart';
import 'package:practica06/presentation/providers/providers.dart';
import 'package:practica06/presentation/widgets/movies/movie_extras.dart';

import 'course_features_test.dart' show movie;

class SearchRepository extends MovieRepositoryImpl {
  SearchRepository() : super(datasource: MoviedbDatasource());
  final searches = <String>[];
  int details = 0;
  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) async => [
    movie(1),
  ];
  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) async => [];
  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) async => [];
  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) async => [];
  @override
  Future<Movie> getMovieById(int id) async {
    details++;
    return movie(id);
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    searches.add(query);
    return [movie(99)];
  }
}

void main() {
  testWidgets(
    'Búsqueda aplica debounce, conserva resultados y regresa a Favoritos',
    (tester) async {
      dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test');
      SharedPreferences.setMockInitialValues({});
      final repository = SearchRepository();
      final database = MoviesDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          movieRepositoryProvider.overrideWithValue(repository),
          moviesDatabaseProvider.overrideWithValue(database),
          movieTrailerProvider.overrideWith((ref, id) async => null),
          castProvider.overrideWith((ref, id) async => []),
          similarMoviesProvider.overrideWith((ref, id) async => []),
          certificationProvider.overrideWith((ref, request) async => null),
        ],
      );
      appRouter.go('/favorites');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Practica06App(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'b');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ba');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'batman');
      await tester.pump(const Duration(milliseconds: 100));
      expect(repository.searches, isEmpty);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(repository.searches, ['batman']);
      await tester.tap(find.text('Película 99'));
      await tester.pumpAndSettle();
      expect(
        appRouter.routerDelegate.currentConfiguration.last.matchedLocation,
        '/movie/99',
      );
      expect(repository.details, 1);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(appRouter.routeInformationProvider.value.uri.path, '/favorites');
      expect(container.read(searchedMoviesProvider).single.id, 99);
      // A second read uses Riverpod's cached detail rather than another HTTP call.
      await container.read(movieDetailsProvider(99).future);
      expect(repository.details, 1);
      await tester.tap(find.byIcon(Icons.category_outlined));
      await tester.pumpAndSettle();
      tester
          .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>))
          .onSelectionChanged!({1});
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.category_outlined));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>))
            .selected,
        {1},
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await database.close();
      appRouter.go('/home');
    },
  );
}
