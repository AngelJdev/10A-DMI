import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practica06/infrastructure/datasources/movie_datasource.dart';
import 'package:practica06/infrastructure/datasources/moviedb_datasource.dart';
import 'package:practica06/infrastructure/repositories/movie_repository_impl.dart';

final movieDatasourceProvider = Provider<MovieDatasource>(
  (ref) => MoviedbDatasource(),
);

final movieRepositoryProvider = Provider((ref) {
  return MovieRepositoryImpl(datasource: ref.watch(movieDatasourceProvider));
});
