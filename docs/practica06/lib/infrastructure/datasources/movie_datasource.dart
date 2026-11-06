import '../../domain/entities/movie.dart';

import 'package:practica06/domain/entities/cast_member.dart';

abstract class MovieDatasource {
  Future<List<Movie>> getNowPlaying({int page = 1, String? region});

  Future<List<Movie>> getPopular({int page = 1, String? region});

  Future<List<Movie>> getTopRated({int page = 1, String? region});

  Future<List<Movie>> getUpcoming({int page = 1, String? region});

  Future<List<Movie>> searchMovies(String query, {int page = 1});

  Future<String?> getCertification(int movieId, String countryCode);

  Future<List<Movie>> getAnime();
  Future<Map<String, dynamic>?> getTrailer(int movieId);
  Future<List<CastMember>> getCast(int movieId);
}
