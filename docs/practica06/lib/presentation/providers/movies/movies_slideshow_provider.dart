import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practica06/domain/entities/movie.dart';

import 'movies_providers.dart';

final moviesSlideshowProvider = Provider<List<Movie>>((ref) {
  final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
  return nowPlayingMovies.take(6).toList();
});
