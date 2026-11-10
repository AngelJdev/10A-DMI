import '../../../app_theme.dart';

import 'package:go_router/go_router.dart';

import '../../widgets/movies/movie_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';
import '../../providers/providers.dart';
import '../../localization/app_copy.dart';
import '../../widgets/shared/scrolling_movie_title.dart';
import '../../widgets/movies/movie_extras.dart';
import '../../widgets/shared/region_flag.dart';

class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({super.key, required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(
      contentFavoriteProvider((id: movie.id, type: movie.mediaType)),
    );
    final isFavorite = favorite.value ?? false;
    final date = movie.releaseDate;
    final region = ref.watch(selectedRegionProvider);
    final copy = AppCopy.of(context);
    const accent = AppTheme.brandColor;
    final certification = ref.watch(
      contentCertificationProvider((
        id: movie.id,
        type: movie.mediaType,
        country: region.code,
      )),
    );
    final screenHeight = MediaQuery.sizeOf(context).height;
    final synopsisLength = movie.overview.trim().length;
    final imageFraction = synopsisLength < 220
        ? 0.55
        : synopsisLength < 480
        ? 0.45
        : 0.36;
    final imageHeight = (screenHeight * imageFraction).clamp(300.0, 540.0);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageHeight,
            pinned: true,
            backgroundColor: const Color(0xff101725),
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: isFavorite
                    ? copy.text('removeFavorite')
                    : copy.text('addFavorite'),
                onPressed: favorite.isLoading
                    ? null
                    : () => _toggleFavorite(context, ref),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xffff5b6e) : Colors.white,
                ),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings
                    >();
                final range =
                    (settings?.maxExtent ?? 1) - (settings?.minExtent ?? 0);
                final expanded = range <= 0
                    ? 1.0
                    : (((settings?.currentExtent ?? constraints.maxHeight) -
                                  (settings?.minExtent ?? 0)) /
                              range)
                          .clamp(0.0, 1.0);
                final horizontalPadding = 64.0 - 44.0 * expanded;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  expandedTitleScale: 1,
                  titlePadding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    16,
                  ),
                  title: ScrollingMovieTitle(
                    title: movie.title,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropPath,
                        fit: BoxFit.cover,
                        loadingBuilder: _imageLoadingBuilder,
                        errorBuilder: (_, _, _) => Image.network(
                          movie.posterPath,
                          fit: BoxFit.cover,
                          loadingBuilder: _imageLoadingBuilder,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: Color(0xffe7e8ed),
                            child: Center(
                              child: Icon(Icons.movie_outlined, size: 64),
                            ),
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                ScrollingMovieTitle(
                  title: movie.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff172033),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xffffad1f)),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      date == null
                          ? copy.text('comingSoon')
                          : '${date.day}/${date.month}/${date.year}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    children: [
                      RegionFlag(region: region, width: 46, height: 31),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clasificación en ${region.country}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            certification.when(
                              loading: () => const Text(
                                'Consultando certificado regional…',
                              ),
                              error: (_, _) => const Text(
                                'No se pudo consultar la clasificación.',
                              ),
                              data: (value) => Text(
                                value == null
                                    ? 'Sin clasificación registrada en TMDB para este país.'
                                    : '${region.ratingSystem}: $value · Referencia en ${region.language}',
                                style: TextStyle(
                                  color: value == null
                                      ? const Color(0xff737987)
                                      : accent,
                                  fontWeight: value == null
                                      ? FontWeight.w400
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  copy.text('synopsis'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.overview.isEmpty
                      ? copy.text('synopsisEmpty')
                      : movie.overview,
                  style: const TextStyle(fontSize: 16, height: 1.55),
                ),
                if (movie.mediaType == MediaType.series) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (movie.seasons != null)
                        Chip(
                          label: Text(
                            '${movie.seasons} ${copy.text('seasons')}',
                          ),
                        ),
                      if (movie.episodes != null)
                        Chip(
                          label: Text(
                            '${movie.episodes} ${copy.text('episodes')}',
                          ),
                        ),
                    ],
                  ),
                ],
                if (movie.genreIds.any(
                  (genre) => int.tryParse(genre) == null,
                )) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: movie.genreIds
                        .where((genre) => int.tryParse(genre) == null)
                        .map((genre) => Chip(label: Text(genre)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 28),
                MovieTrailer(movieId: movie.id, mediaType: movie.mediaType),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: favorite.isLoading
                      ? null
                      : () => _toggleFavorite(context, ref),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite
                        ? copy.text('savedFavorite')
                        : copy.text('addFavorite'),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  copy.text('cast'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actores y personajes · En animación, voces del reparto original',
                  style: TextStyle(color: Color(0xff666e7a)),
                ),
                const SizedBox(height: 16),
                ref
                    .watch(
                      contentCastProvider((
                        id: movie.id,
                        type: movie.mediaType,
                      )),
                    )
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => TextButton.icon(
                        onPressed: () => ref.invalidate(
                          contentCastProvider((
                            id: movie.id,
                            type: movie.mediaType,
                          )),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: Text(copy.text('retry')),
                      ),
                      data: (cast) => cast.isEmpty
                          ? const Text(
                              'No hay reparto disponible para esta película.',
                            )
                          : Wrap(
                              spacing: 12,
                              runSpacing: 20,
                              children: cast
                                  .map(
                                    (actor) => SizedBox(
                                      width:
                                          (MediaQuery.sizeOf(context).width -
                                              64) /
                                          3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: 0.72,
                                              child: actor.photo == null
                                                  ? const ColoredBox(
                                                      color: Color(0xffe9edf3),
                                                      child: Icon(
                                                        Icons.person_outline,
                                                        size: 42,
                                                      ),
                                                    )
                                                  : Image.network(
                                                      actor.photo!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, _, _) =>
                                                          const ColoredBox(
                                                            color: Color(
                                                              0xffe9edf3,
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .person_outline,
                                                              size: 42,
                                                            ),
                                                          ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            actor.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (actor.character.isNotEmpty)
                                            Text(
                                              actor.character,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff666e7a),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                const SizedBox(height: 24),
                ref
                    .watch(
                      contentSimilarProvider((
                        id: movie.id,
                        type: movie.mediaType,
                      )),
                    )
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => TextButton(
                        onPressed: () => ref.invalidate(
                          contentSimilarProvider((
                            id: movie.id,
                            type: movie.mediaType,
                          )),
                        ),
                        child: Text(copy.text('retry')),
                      ),
                      data: (movies) => movies.isEmpty
                          ? const SizedBox.shrink()
                          : MovieSection(
                              title: movie.mediaType == MediaType.series
                                  ? copy.text('similarSeries')
                                  : 'Películas similares',
                              movies: movies,
                              onMovieTap: (selected) => context.push(
                                selected.location,
                                extra: selected,
                              ),
                            ),
                    ),
                const SizedBox(height: 24),
                MovieReviews(
                  key: ValueKey('reviews-${movie.contentKey}'),
                  movieId: movie.id,
                  mediaType: movie.mediaType,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(favoriteMoviesProvider.notifier).toggle(movie);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar el favorito. Intenta nuevamente.',
            ),
          ),
        );
      }
    }
  }

  Widget _imageLoadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    if (progress == null) return child;
    final expected = progress.expectedTotalBytes;
    return ColoredBox(
      color: const Color(0xffe7e8ed),
      child: Center(
        child: CircularProgressIndicator(
          value: expected == null
              ? null
              : progress.cumulativeBytesLoaded / expected,
        ),
      ),
    );
  }
}
