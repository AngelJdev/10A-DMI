import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import '../providers/providers.dart';
import '../localization/app_copy.dart';
import '../widgets/movies/movie_masonry.dart';

class PopularView extends ConsumerStatefulWidget {
  const PopularView({super.key, required this.onMovieTap});
  final ValueChanged<Movie> onMovieTap;
  @override
  ConsumerState<PopularView> createState() => _PopularViewState();
}

class _PopularViewState extends ConsumerState<PopularView> {
  int _category = 0;
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final provider = [
      popularMoviesProvider,
      topRatedMoviesProvider,
      upcomingMoviesProvider,
    ][_category];
    final movies = ref.watch(provider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 0, label: Text(copy.text('popular'))),
                ButtonSegment(value: 1, label: Text(copy.text('topRated'))),
                ButtonSegment(
                  value: 2,
                  label: Text(
                    copy.text(
                      ref.watch(selectedMediaProvider) == MediaType.series
                          ? 'airingToday'
                          : 'upcoming',
                    ),
                  ),
                ),
              ],
              selected: {_category},
              onSelectionChanged: (value) =>
                  setState(() => _category = value.single),
            ),
          ),
        ),
        Expanded(
          child: movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        copy.text(
                          ref.watch(selectedMediaProvider) == MediaType.series
                              ? 'emptySeries'
                              : 'emptyRegion',
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(copy.text('retry')),
                        onPressed: () async {
                          try {
                            await ref.read(provider.notifier).loadNextPage();
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No se pudo cargar el catálogo.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              : MovieMasonry(
                  movies: movies,
                  onMovieTap: widget.onMovieTap,
                  storageKey:
                      'catalog-$_category-${ref.watch(selectedRegionProvider).code}-${ref.watch(selectedMediaProvider).name}',
                  loadNextPage: ref.read(provider.notifier).loadNextPage,
                ),
        ),
      ],
    );
  }
}
