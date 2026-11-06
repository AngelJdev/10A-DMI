import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practica06/domain/entities/cast_member.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/domain/entities/region_profile.dart';
import 'package:practica06/infrastructure/repositories/movies_repository_provider.dart';

final nowPlayingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(movieRepositoryProvider);

      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getNowPlaying(page: page, region: region),
      );
    });

final upcomingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(movieRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getUpcoming(page: page, region: region),
      );
    });

final popularMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(movieRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getPopular(page: page, region: region),
      );
    });

final topRatedMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final region = ref.watch(selectedRegionProvider).code;
      final repository = ref.watch(movieRepositoryProvider);
      return MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) =>
            repository.getTopRated(page: page, region: region),
      );
    });

final favoriteMoviesProvider =
    StateNotifierProvider<FavoriteMoviesNotifier, List<Movie>>(
      (ref) => FavoriteMoviesNotifier(),
    );

final selectedRegionProvider = StateProvider<RegionProfile>(
  (ref) => regionProfiles.first,
);

final animeMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).getAnime(),
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

class FavoriteMoviesNotifier extends StateNotifier<List<Movie>> {
  FavoriteMoviesNotifier() : super([]);

  void toggle(Movie movie) {
    state = state.any((item) => item.id == movie.id)
        ? state.where((item) => item.id != movie.id).toList()
        : [...state, movie];
  }
}

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  MoviesNotifier({required this.fetchMoreMovies}) : super([]);

  final MovieCallback fetchMoreMovies;
  int currentPage = 0;

  Future<void> loadNextPage() async {
    final nextPage = currentPage + 1;
    final movies = await fetchMoreMovies(page: nextPage);
    if (!mounted) return;
    currentPage = nextPage;
    state = [...state, ...movies];
  }
}
