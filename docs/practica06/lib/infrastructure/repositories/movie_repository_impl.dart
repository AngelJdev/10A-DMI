import '../../domain/entities/video.dart';

import 'package:practica06/infrastructure/datasources/movie_datasource.dart';
import 'package:practica06/domain/entities/cast_member.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/domain/repositories/movies_repositories.dart';

class MovieRepositoryImpl extends MoviesRepository {
  @override
  Future<Movie> getMovieById(int id) => datasource.getMovieById(id);
  @override
  Future<List<Movie>> getSimilar(int id, {int page = 1}) =>
      datasource.getSimilar(id, page: page);
  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) =>
      datasource.getYoutubeVideosById(movieId);
  @override
  Future<List<Movie>> getAnime() => datasource.getAnime();
  @override
  Future<List<CastMember>> getCast(int movieId) => datasource.getCast(movieId);
  final MovieDatasource datasource;

  MovieRepositoryImpl({required this.datasource});

  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) {
    return datasource.getNowPlaying(page: page, region: region);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) {
    return datasource.getPopular(page: page, region: region);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) {
    return datasource.getTopRated(page: page, region: region);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) {
    return datasource.getUpcoming(page: page, region: region);
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) {
    return datasource.searchMovies(query, page: page);
  }

  @override
  Future<String?> getCertification(int movieId, String countryCode) {
    return datasource.getCertification(movieId, countryCode);
  }
}
