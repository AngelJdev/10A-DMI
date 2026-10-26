import 'package:dio/dio.dart';

import '../config/constants/environment.dart';
import 'datasources/movies_datasource.dart';
import '../domain/entities/movie.dart';
import 'mappers/movie_mapper.dart';
import 'models/moviedb/moviedb_response.dart';

class MoviedbDatasource extends MoviesDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': 'es-MX',
      },
    ),
  );

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
        .where((moviedb) => moviedb.posterPath?.isNotEmpty ?? false)
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data ?? const {});
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/popular',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data ?? const {});
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data ?? const {});
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/upcoming',
      queryParameters: {'page': page},
    );

    return _jsonToMovies(response.data ?? const {});
  }
}
