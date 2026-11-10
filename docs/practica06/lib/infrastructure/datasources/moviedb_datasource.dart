import '../../domain/entities/video.dart';
import '../models/moviedb/moviedb_video.dart';
import '../mappers/video_mapper.dart';

import 'package:dio/dio.dart';
import 'package:practica06/domain/entities/cast_member.dart';

import '../../config/constants/environment.dart';
import 'movie_datasource.dart';
import '../../domain/entities/movie.dart';
import '../mappers/movie_mapper.dart';
import '../models/moviedb/moviedb_response.dart';
import '../models/moviedb/movie_details.dart';

class MoviedbDatasource extends MovieDatasource {
  MoviedbDatasource({this.language = 'es-MX'});
  final String language;
  @override
  Future<Movie> getMovieById(int id) async {
    final response = await dio.get<Map<String, dynamic>>('/movie/$id');
    return MovieMapper.movieDetailsToEntity(
      MovieDetails.fromJson(response.data ?? {}),
    );
  }

  @override
  Future<List<Movie>> getSimilar(int id, {int page = 1}) =>
      _getNowMovies('/movie/$id/similar', page: page);

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/movie/$movieId/videos',
      queryParameters: {
        'language': language,
        'include_video_language': '${language.split('-').first},en,null',
      },
    );
    final raw = response.data?['results'];
    if (raw is! List) return [];
    final videos = raw
        .whereType<Map<String, dynamic>>()
        .map(MoviedbVideo.fromJson)
        .where(
          (video) =>
              video.site == 'YouTube' &&
              RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(video.key),
        )
        .map(VideoMapper.toEntity)
        .toList();
    int rank(Video video) =>
        (video.type == 'Trailer' ? 0 : 4) +
        (video.language == 'es' ? 0 : 2) +
        (video.official ? 0 : 1);
    videos.sort((a, b) => rank(a).compareTo(rank(b)));
    return videos;
  }

  @override
  Future<List<Movie>> getAnime() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: {
        'with_origin_country': 'JP',
        'with_genres': '16',
        'language': language,
        'sort_by': 'popularity.desc',
        'include_adult': false,
      },
    );
    return MovieDbResponse.fromJson(response.data ?? const {}).results
        .map(MovieMapper.movieDBToEntity)
        .toList();
  }

  @override
  Future<List<CastMember>> getCast(int movieId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/movie/$movieId/credits',
    );
    final cast = response.data?['cast'];
    if (cast is! List) return [];
    return cast
        .whereType<Map<String, dynamic>>()
        .map(CastMember.fromJson)
        .toList();
  }

  late final Dio dio = Dio(
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

  Future<List<Movie>> _getNowMovies(
    String endpoint, {
    required int page,
    String? region,
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (region != null) queryParameters['region'] = region;
    final response = await dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParameters,
    );
    final movieDBResponse = MovieDbResponse.fromJson(response.data ?? const {});

    final List<Movie> movies = movieDBResponse.results
        .where(
          (moviedb) =>
              moviedb.posterPath != null &&
              moviedb.posterPath!.isNotEmpty &&
              moviedb.posterPath != 'no-poster',
        )
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();

    return movies;
  }

  Future<List<Movie>> _getRegionalMovies(
    String countryCode, {
    required int page,
    required String sortBy,
    bool upcoming = false,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final response = await dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: {
        'language': _localeForRegion(countryCode),
        'page': page,
        'with_origin_country': countryCode,
        'sort_by': sortBy,
        'include_adult': false,
        if (upcoming) 'primary_release_date.gte': today,
        if (!upcoming) 'primary_release_date.lte': today,
        if (sortBy == 'vote_average.desc') 'vote_count.gte': 20,
      },
    );
    final movieDBResponse = MovieDbResponse.fromJson(response.data ?? const {});
    return movieDBResponse.results
        .where(
          (movie) =>
              movie.posterPath != null &&
              movie.posterPath!.isNotEmpty &&
              movie.posterPath != 'no-poster',
        )
        .map(MovieMapper.movieDBToEntity)
        .toList();
  }

  String _localeForRegion(String countryCode) => switch (countryCode) {
    'US' || 'AU' => 'en-US',
    'BR' => 'pt-BR',
    'DE' => 'de-DE',
    'JP' => 'ja-JP',
    'CD' => 'fr-FR',
    'SV' => 'es-SV',
    _ => 'es-MX',
  };

  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) =>
      region == null
      ? _getNowMovies('/movie/now_playing', page: page)
      : _getRegionalMovies(region, page: page, sortBy: 'popularity.desc');

  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) =>
      region == null
      ? _getNowMovies('/movie/popular', page: page)
      : _getRegionalMovies(region, page: page, sortBy: 'popularity.desc');

  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) =>
      region == null
      ? _getNowMovies('/movie/top_rated', page: page)
      : _getRegionalMovies(region, page: page, sortBy: 'vote_average.desc');

  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) =>
      region == null
      ? _getNowMovies('/movie/upcoming', page: page)
      : _getRegionalMovies(
          region,
          page: page,
          sortBy: 'primary_release_date.asc',
          upcoming: true,
        );

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return const [];
    final response = await dio.get<Map<String, dynamic>>(
      '/search/movie',
      queryParameters: {
        'query': query.trim(),
        'page': page,
        'include_adult': false,
      },
    );
    final movieDBResponse = MovieDbResponse.fromJson(response.data ?? const {});
    return movieDBResponse.results
        .where(
          (movie) =>
              movie.posterPath != null &&
              movie.posterPath!.isNotEmpty &&
              movie.posterPath != 'no-poster',
        )
        .map(MovieMapper.movieDBToEntity)
        .toList();
  }

  @override
  Future<String?> getCertification(int movieId, String countryCode) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/movie/$movieId/release_dates',
    );
    final results = response.data?['results'];
    if (results is! List) return null;
    for (final entry in results.whereType<Map<String, dynamic>>()) {
      if (entry['iso_3166_1'] != countryCode) continue;
      final dates = entry['release_dates'];
      if (dates is! List) return null;
      final releases = dates.whereType<Map<String, dynamic>>().toList()
        ..sort((a, b) {
          final aType = a['type'] == 3 ? 0 : 1;
          final bType = b['type'] == 3 ? 0 : 1;
          return aType.compareTo(bType);
        });
      for (final release in releases) {
        final certification = release['certification']?.toString().trim();
        if (certification != null && certification.isNotEmpty) {
          return certification;
        }
      }
    }
    return null;
  }
}
