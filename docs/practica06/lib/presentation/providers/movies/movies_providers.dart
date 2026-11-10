import '../catalog_preferences.dart';
export '../catalog_preferences.dart';
import '../../../infrastructure/database/movies_database.dart';
import '../../../infrastructure/repositories/drift_storage_repository.dart';
import '../../../domain/repositories/local_storage_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practica06/domain/entities/cast_member.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/infrastructure/repositories/movies_repository_provider.dart';

typedef ContentRequest = ({int id, MediaType type});
final activeRepositoryProvider = Provider((ref) {
  final type = ref.watch(selectedMediaProvider);
  return type == MediaType.movie
      ? ref.watch(movieRepositoryProvider)
      : ref.watch(
          seriesRepositoryProvider(ref.watch(selectedRegionProvider).locale),
        );
});
final contentDetailsProvider = FutureProvider.family<Movie, ContentRequest>(
  (ref, request) => request.type == MediaType.movie
      ? ref.watch(movieDetailsProvider(request.id).future)
      : ref
            .watch(
              seriesRepositoryProvider(
                ref.watch(selectedRegionProvider).locale,
              ),
            )
            .getMovieById(request.id),
);
final contentCastProvider =
    FutureProvider.family<List<CastMember>, ContentRequest>(
      (ref, request) => request.type == MediaType.movie
          ? ref.watch(castProvider(request.id).future)
          : ref
                .watch(
                  seriesRepositoryProvider(
                    ref.watch(selectedRegionProvider).locale,
                  ),
                )
                .getCast(request.id),
    );
final contentSimilarProvider =
    FutureProvider.family<List<Movie>, ContentRequest>(
      (ref, request) => request.type == MediaType.movie
          ? ref.watch(similarMoviesProvider(request.id).future)
          : ref
                .watch(
                  seriesRepositoryProvider(
                    ref.watch(selectedRegionProvider).locale,
                  ),
                )
                .getSimilar(request.id),
    );
final contentFavoriteProvider = FutureProvider.family<bool, ContentRequest>((
  ref,
  request,
) {
  ref.watch(favoriteMoviesProvider);
  return ref
      .watch(localStorageProvider)
      .isFavorite(request.id, type: request.type);
});
final contentCertificationProvider =
    FutureProvider.family<String?, ({int id, MediaType type, String country})>(
      (ref, request) => request.type == MediaType.movie
          ? ref.watch(
              certificationProvider((
                movieId: request.id,
                countryCode: request.country,
              )).future,
            )
          : ref
                .watch(
                  seriesRepositoryProvider(
                    ref.watch(selectedRegionProvider).locale,
                  ),
                )
                .getCertification(request.id, request.country),
    );

final nowPlayingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(activeRepositoryProvider);

      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getNowPlaying(page: page, region: region),
      );
    });

final upcomingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(activeRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getUpcoming(page: page, region: region),
      );
    });

final popularMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(activeRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getPopular(page: page, region: region),
      );
    });

final topRatedMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(activeRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getTopRated(page: page, region: region),
      );
    });

final moviesDatabaseProvider = Provider<MoviesDatabase>((ref) {
  final database = MoviesDatabase.open();
  ref.onDispose(database.close);
  return database;
});
final localStorageProvider = Provider<LocalStorageRepository>(
  (ref) => DriftStorageRepository(ref.watch(moviesDatabaseProvider)),
);
final favoriteMoviesProvider =
    AsyncNotifierProvider<FavoriteMoviesNotifier, List<Movie>>(
      FavoriteMoviesNotifier.new,
    );
final isFavoriteProvider = FutureProvider.family<bool, int>((ref, id) {
  ref.watch(favoriteMoviesProvider);
  return ref.watch(localStorageProvider).isFavorite(id);
});
final movieDetailsProvider = FutureProvider.family<Movie, int>(
  (ref, id) => ref.watch(movieRepositoryProvider).getMovieById(id),
);
final similarMoviesProvider = FutureProvider.family<List<Movie>, int>(
  (ref, id) => ref.watch(movieRepositoryProvider).getSimilar(id),
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchedMoviesProvider = StateProvider<List<Movie>>((ref) => []);

final animeMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(activeRepositoryProvider).getAnime(),
);
final castProvider = FutureProvider.family<List<CastMember>, int>(
  (ref, id) => ref.watch(movieRepositoryProvider).getCast(id),
);

final certificationProvider =
    FutureProvider.family<String?, ({int movieId, String countryCode})>((
      ref,
      request,
    ) {
      return ref
          .watch(movieRepositoryProvider)
          .getCertification(request.movieId, request.countryCode);
    });

class FavoriteMoviesNotifier extends AsyncNotifier<List<Movie>> {
  bool hasMore = true;
  bool _loading = false;
  int _revision = 0;
  final Set<String> _saving = {};
  MediaType _type = MediaType.movie;

  @override
  Future<List<Movie>> build() async {
    _type = ref.watch(selectedMediaProvider);
    final revision = ++_revision;
    final movies = await ref
        .watch(localStorageProvider)
        .loadMovies(type: _type);
    if (ref.mounted && revision == _revision) hasMore = movies.length == 20;
    return movies;
  }

  Future<void> loadNextPage() async {
    if (_loading ||
        !hasMore ||
        state.isLoading ||
        state.hasError ||
        _saving.isNotEmpty) {
      return;
    }
    _loading = true;
    final revision = _revision;
    try {
      final current = state.value ?? [];
      final next = await ref
          .read(localStorageProvider)
          .loadMovies(offset: current.length, type: _type);
      if (!ref.mounted || revision != _revision) return;
      hasMore = next.length == 20;
      state = AsyncData([...current, ...next]);
    } finally {
      _loading = false;
    }
  }

  Future<void> toggle(Movie movie) async {
    if (!_saving.add(movie.contentKey)) return;
    _revision++;
    try {
      await future;
      final storage = ref.read(localStorageProvider);
      await storage.toggleFavorite(movie);
      // Reload the visible window so offsets stay correct after deletion.
      final limit = (state.value?.length ?? 20) + 1;
      final revision = _revision;
      final movies = await storage.loadMovies(limit: limit, type: _type);
      if (!ref.mounted || revision != _revision) return;
      hasMore = movies.length == limit;
      state = AsyncData(movies);
    } finally {
      _saving.remove(movie.contentKey);
    }
  }
}

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  MoviesNotifier({required this.fetchMoreMovies}) : super([]);

  final MovieCallback fetchMoreMovies;
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    try {
      final nextPage = currentPage + 1;
      final movies = await fetchMoreMovies(page: nextPage);
      if (!mounted) return;
      currentPage = nextPage;
      hasMore = movies.isNotEmpty;
      final byId = {
        for (final movie in [...state, ...movies]) movie.contentKey: movie,
      };
      state = byId.values.toList();
    } finally {
      isLoading = false;
    }
  }
}
