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
    final isFavorite = ref
        .watch(favoriteMoviesProvider)
        .any((item) => item.id == movie.id);
    final date = movie.releaseDate;
    final region = ref.watch(selectedRegionProvider);
    final copy = AppCopy.of(context);
    final accent = Color(region.accentValue);
    final certification = ref.watch(
      certificationProvider((movieId: movie.id, countryCode: region.code)),
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
                onPressed: () =>
                    ref.read(favoriteMoviesProvider.notifier).toggle(movie),
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
                const SizedBox(height: 28),
                MovieTrailer(movieId: movie.id),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(favoriteMoviesProvider.notifier).toggle(movie),
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
                    .watch(castProvider(movie.id))
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => TextButton.icon(
                        onPressed: () => ref.invalidate(castProvider(movie.id)),
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
                MovieReviews(
                  key: ValueKey('reviews-${movie.id}'),
                  movieId: movie.id,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
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
