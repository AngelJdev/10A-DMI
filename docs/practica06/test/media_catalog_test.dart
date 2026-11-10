import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show MigrationStrategy;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practica06/main.dart';
import 'package:practica06/app_router.dart';
import 'package:practica06/app_theme.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/domain/repositories/local_storage_repository.dart';
import 'package:practica06/domain/entities/region_profile.dart';
import 'package:practica06/infrastructure/database/movies_database.dart';
import 'package:practica06/infrastructure/datasources/moviedb_datasource.dart';
import 'package:practica06/infrastructure/repositories/movie_repository_impl.dart';
import 'package:practica06/infrastructure/repositories/movies_repository_provider.dart';
import 'package:practica06/infrastructure/repositories/drift_storage_repository.dart';
import 'package:practica06/infrastructure/repositories/local_reviews_repository.dart';
import 'package:practica06/presentation/providers/providers.dart';
import 'package:practica06/presentation/screens/movies/movie_detail_screen.dart';
import 'package:practica06/presentation/widgets/movies/movie_extras.dart';
import 'package:practica06/presentation/widgets/shared/region_loading_overlay.dart';

import 'course_features_test.dart' show movie;

Movie series(int id) => Movie.fromJson({
  ...movie(id).toJson(),
  'title': 'Serie $id',
  'mediaType': 'series',
  'seasons': 2,
  'episodes': 16,
});

class LegacyDatabase extends MoviesDatabase {
  LegacyDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => customStatement(
      'CREATE TABLE favorite_entries (movie_id INTEGER NOT NULL PRIMARY KEY, payload TEXT NOT NULL, saved_at INTEGER NOT NULL)',
    ),
  );
}

class CatalogRepository extends MovieRepositoryImpl {
  CatalogRepository(this.type) : super(datasource: MoviedbDatasource());
  final MediaType type;
  Movie item(int id) => type == MediaType.series ? series(id) : movie(id);
  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) async =>
      List.generate(30, (i) => item(i + 1));
  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) async => [
    item(40),
  ];
  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) async => [
    item(50),
  ];
  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) async =>
      List.generate(20, (i) => item(i + 60));
  @override
  Future<Movie> getMovieById(int id) async => item(id);
  @override
  Future<List<Movie>> getSimilar(int id, {int page = 1}) async => [];
}

class DelayedStorage implements LocalStorageRepository {
  final nextPage = Completer<List<Movie>>();
  @override
  Future<List<Movie>> loadMovies({
    int offset = 0,
    int limit = 20,
    MediaType? type,
  }) async {
    if (type == MediaType.series) return [series(1)];
    return offset == 0
        ? List.generate(20, (i) => movie(i + 1))
        : nextPage.future;
  }

  @override
  Future<bool> isFavorite(
    int movieId, {
    MediaType type = MediaType.movie,
  }) async => false;
  @override
  Future<void> toggleFavorite(Movie movie) async {}
}

Future<void> capture(WidgetTester tester, String filename) async {
  if (!const bool.fromEnvironment('CAPTURE_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('preview-boundary')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/previews/$filename.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (!const bool.fromEnvironment('CAPTURE_PREVIEWS')) return;
    final fontRoot =
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts';
    for (final entry in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
    ]) {
      final file = File('$fontRoot/${entry.$2}');
      if (await file.exists()) {
        final loader = FontLoader(entry.$1)
          ..addFont(
            Future.value(ByteData.sublistView(await file.readAsBytes())),
          );
        await loader.load();
      }
    }
  });
  setUp(() {
    dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test');
    SharedPreferences.setMockInitialValues({});
  });

  test('Migración de favoritos conserva películas y permite una serie con el mismo ID', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cinemapedia-migration-',
    );
    final file = File('${directory.path}/favorites.sqlite');
    final old = LegacyDatabase(NativeDatabase(file));
    final payload = movie(7).toJson()..remove('mediaType');
    await old.customStatement('INSERT INTO favorite_entries VALUES (?, ?, ?)', [
      7,
      jsonEncode(payload),
      0,
    ]);
    await old.close();
    final database = MoviesDatabase(NativeDatabase(file));
    try {
      final storage = DriftStorageRepository(database);
      expect((await storage.loadMovies()).single.title, movie(7).title);
      await storage.toggleFavorite(series(7));
      expect(await storage.isFavorite(7), isTrue);
      expect(await storage.isFavorite(7, type: MediaType.series), isTrue);
      expect(
        (await storage.loadMovies(type: MediaType.series)).single.title,
        'Serie 7',
      );
      await storage.toggleFavorite(series(7));
      expect(await storage.isFavorite(7), isTrue);
      expect(await storage.isFavorite(7, type: MediaType.series), isFalse);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'Reseñas de película y serie con igual ID se guardan por separado',
    () async {
      final repository = LocalReviewsRepository();
      final review = LocalReview(
        text: 'Sólo para la serie',
        stars: 5,
        created: DateTime(2026),
      );
      await repository.save(7, [review], type: MediaType.series);
      expect(await repository.load(7), isEmpty);
      expect(
        (await repository.load(7, type: MediaType.series)).single.text,
        review.text,
      );
    },
  );

  test('Una página atrasada de favoritos no contamina el catálogo al cambiar a Series', () async {
    final storage = DelayedStorage();
    final container = ProviderContainer(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(favoriteMoviesProvider.future);
    final pending = container
        .read(favoriteMoviesProvider.notifier)
        .loadNextPage();
    container.read(selectedMediaProvider.notifier).state = MediaType.series;
    expect(
      (await container.read(favoriteMoviesProvider.future)).single.mediaType,
      MediaType.series,
    );
    storage.nextPage.complete([movie(21)]);
    await pending;
    expect(
      container.read(favoriteMoviesProvider).value!.single.mediaType,
      MediaType.series,
    );
  });

  testWidgets(
    'Feed conserva el scroll al volver de Favoritos y abre detalles de series',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final database = MoviesDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          movieRepositoryProvider.overrideWithValue(
            CatalogRepository(MediaType.movie),
          ),
          seriesRepositoryProvider.overrideWith(
            (ref, locale) => CatalogRepository(MediaType.series),
          ),
          moviesDatabaseProvider.overrideWithValue(database),
          castProvider.overrideWith((ref, id) async => []),
          certificationProvider.overrideWith((ref, request) async => null),
          contentCastProvider.overrideWith((ref, request) async => []),
          contentCertificationProvider.overrideWith(
            (ref, request) async => null,
          ),
          contentTrailerProvider.overrideWith((ref, request) async => null),
        ],
      );
      appRouter.go('/home');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RepaintBoundary(
            key: ValueKey('preview-boundary'),
            child: Practica06App(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Finder feed(MediaType type) =>
          find.byKey(PageStorageKey('home-feed-${type.name}-MX'));
      double offset(MediaType type) => tester
          .state<ScrollableState>(
            find
                .descendant(of: feed(type), matching: find.byType(Scrollable))
                .first,
          )
          .position
          .pixels;
      await tester.drag(feed(MediaType.movie), const Offset(0, -1200));
      await tester.pumpAndSettle();
      final before = offset(MediaType.movie);
      expect(before, greaterThan(100));
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(offset(MediaType.movie), closeTo(before, 0.5));
      await tester.tap(find.byKey(const ValueKey('media-series')));
      await tester.pumpAndSettle();
      expect(
        container.read(nowPlayingMoviesProvider).first.mediaType,
        MediaType.series,
      );
      expect(feed(MediaType.series), findsOneWidget);
      await tester.drag(feed(MediaType.series), const Offset(0, -1200));
      await tester.pumpAndSettle();
      final seriesOffset = offset(MediaType.series);
      expect(seriesOffset, greaterThan(100));
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(offset(MediaType.series), closeTo(seriesOffset, 0.5));
      await tester.drag(feed(MediaType.series), const Offset(0, 1200));
      await tester.pumpAndSettle();
      await capture(tester, 'series-home');
      appRouter.push('/series/7', extra: series(7));
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailScreen), findsOneWidget);
      expect(find.text('2 temporadas'), findsOneWidget);
      appRouter.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('media-movie')));
      await tester.pumpAndSettle();
      expect(offset(MediaType.movie), closeTo(before, 0.5));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await database.close();
      appRouter.go('/home');
    },
  );

  testWidgets('Transición de idioma usa la paleta estable de la app', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('preview-boundary'),
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          home: Scaffold(
            body: RegionLoadingOverlay(
              region: regionProfiles.firstWhere((r) => r.code == 'BR'),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Preparando seu catálogo'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .color,
      AppTheme.brandColor,
    );
    await capture(tester, 'language-transition');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
