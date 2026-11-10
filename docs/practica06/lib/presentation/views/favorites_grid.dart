import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/movies/movie_masonry.dart';

import '../../domain/entities/movie.dart';
import '../localization/app_copy.dart';
import '../providers/providers.dart';

class FavoritesGrid extends ConsumerWidget {
  const FavoritesGrid({super.key, required this.onMovieTap});
  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    return ref
        .watch(favoriteMoviesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(favoriteMoviesProvider),
              icon: const Icon(Icons.refresh),
              label: Text(copy.text('retry')),
            ),
          ),
          data: (movies) {
            if (movies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: Color(0xffa0a3ad),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      copy.text('noFavorites'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.text(
                        ref.watch(selectedMediaProvider) == MediaType.series
                            ? 'seriesFavoriteHint'
                            : 'favoriteHint',
                      ),
                    ),
                  ],
                ),
              );
            }
            return MovieMasonry(
              movies: movies,
              onMovieTap: onMovieTap,
              storageKey:
                  'favorites-grid-${ref.watch(selectedMediaProvider).name}',
              loadNextPage: ref
                  .read(favoriteMoviesProvider.notifier)
                  .loadNextPage,
            );
          },
        );
  }
}
