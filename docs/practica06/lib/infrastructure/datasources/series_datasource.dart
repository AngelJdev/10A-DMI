import 'package:dio/dio.dart';

import '../../domain/entities/movie.dart';
import '../../domain/entities/cast_member.dart';
import '../../domain/entities/video.dart';
import '../../config/constants/environment.dart';
import '../mappers/series_mapper.dart';
import '../mappers/video_mapper.dart';
import '../models/moviedb/moviedb_video.dart';
import 'movie_datasource.dart';

class SeriesDatasource extends MovieDatasource {
  SeriesDatasource({this.language = 'es-MX', Dio? client})
    : dio =
          client ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.themoviedb.org/3',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              queryParameters: {
                'api_key': Environment.theMovieDbKey,
                'language': language,
              },
            ),
          );
  final String language;
  final Dio dio;

  Future<List<Movie>> _list(
    String path, {
    int page = 1,
    Map<String, dynamic> query = const {},
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'page': page, ...query},
    );
    final results = response.data?['results'];
    if (results is! List) return [];
    return results
        .whereType<Map<String, dynamic>>()
        .where(
          (item) =>
              item['poster_path'] is String &&
              (item['poster_path'] as String).isNotEmpty,
        )
        .map(SeriesMapper.toEntity)
        .toList();
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) =>
      _list('/tv/on_the_air', page: page);
  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) =>
      _list('/tv/popular', page: page);
  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) =>
      _list('/tv/top_rated', page: page);
  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) =>
      _list('/tv/airing_today', page: page);
  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) =>
      query.trim().isEmpty
      ? Future.value([])
      : _list(
          '/search/tv',
          page: page,
          query: {'query': query.trim(), 'include_adult': false},
        );
  @override
  Future<Movie> getMovieById(int id) async {
    final response = await dio.get<Map<String, dynamic>>('/tv/$id');
    return SeriesMapper.toEntity(response.data ?? {});
  }

  @override
  Future<List<Movie>> getSimilar(int id, {int page = 1}) =>
      _list('/tv/$id/similar', page: page);
  @override
  Future<List<Movie>> getAnime() => _list(
    '/discover/tv',
    query: {
      'with_origin_country': 'JP',
      'with_genres': '16',
      'sort_by': 'popularity.desc',
      'include_adult': false,
    },
  );
  @override
  Future<List<CastMember>> getCast(int movieId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/tv/$movieId/credits',
    );
    final results = response.data?['cast'];
    return results is List
        ? results
              .whereType<Map<String, dynamic>>()
              .map(CastMember.fromJson)
              .toList()
        : [];
  }

  @override
  Future<String?> getCertification(int movieId, String countryCode) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/tv/$movieId/content_ratings',
    );
    final results = response.data?['results'];
    if (results is! List) return null;
    for (final item in results.whereType<Map<String, dynamic>>()) {
      if (item['iso_3166_1'] == countryCode && item['rating'] is String) {
        final rating = (item['rating'] as String).trim();
        if (rating.isNotEmpty) return rating;
      }
    }
    return null;
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/tv/$movieId/videos',
      queryParameters: {
        'include_video_language': '${language.split('-').first},en,null',
      },
    );
    final results = response.data?['results'];
    if (results is! List) return [];
    final videos = results
        .whereType<Map<String, dynamic>>()
        .map(MoviedbVideo.fromJson)
        .where(
          (v) =>
              v.site == 'YouTube' &&
              RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(v.key),
        )
        .map(VideoMapper.toEntity)
        .toList();
    int rank(Video v) =>
        (v.type == 'Trailer' ? 0 : 4) +
        (v.language == language.split('-').first ? 0 : 2) +
        (v.official ? 0 : 1);
    videos.sort((a, b) => rank(a).compareTo(rank(b)));
    return videos;
  }
}
