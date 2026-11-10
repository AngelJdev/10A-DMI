import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../domain/entities/movie.dart';

class MovieMasonry extends StatelessWidget {
  const MovieMasonry({
    super.key,
    required this.movies,
    required this.onMovieTap,
    required this.storageKey,
    this.loadNextPage,
  });
  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;
  final String storageKey;
  final Future<void> Function()? loadNextPage;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 350 && loadNextPage != null) {
            loadNextPage!().catchError((Object _) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se pudieron cargar más películas. Desliza para reintentar.',
                    ),
                  ),
                );
              }
            });
          }
          return false;
        },
        child: MasonryGridView.count(
          key: PageStorageKey(storageKey),
          padding: const EdgeInsets.all(16),
          crossAxisCount: (MediaQuery.sizeOf(context).width / 180)
              .floor()
              .clamp(2, 6),
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return InkWell(
              onTap: () => onMovieTap(movie),
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: index.isEven ? 0.65 : 0.75,
                      child: Image.network(
                        movie.posterPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xffe7e8ed),
                          child: Icon(Icons.movie_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('★ ${movie.voteAverage.toStringAsFixed(1)}'),
                ],
              ),
            );
          },
        ),
      );
}
