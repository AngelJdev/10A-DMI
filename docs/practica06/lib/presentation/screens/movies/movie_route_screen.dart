import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';
import '../../providers/providers.dart';
import 'movie_detail_screen.dart';

class MovieRouteScreen extends ConsumerWidget {
  const MovieRouteScreen({
    super.key,
    required this.movieId,
    this.initialMovie,
    this.mediaType = MediaType.movie,
  });
  final int movieId;
  final MediaType mediaType;
  final Movie? initialMovie;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(contentDetailsProvider((id: movieId, type: mediaType)))
      .when(
        data: (movie) => MovieDetailScreen(movie: movie),
        loading: () => Scaffold(
          appBar: AppBar(title: Text(initialMovie?.title ?? 'Cinemapedia')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => initialMovie != null
            ? MovieDetailScreen(movie: initialMovie!)
            : Scaffold(
                appBar: AppBar(title: const Text('Cinemapedia')),
                body: Center(
                  child: TextButton.icon(
                    onPressed: () => ref.invalidate(
                      contentDetailsProvider((id: movieId, type: mediaType)),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'No se pudo cargar el título. Reintentar',
                    ),
                  ),
                ),
              ),
      );
}
