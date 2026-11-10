import '../../domain/entities/video.dart';
import '../../domain/entities/movie.dart';

import 'package:practica06/domain/entities/cast_member.dart';

abstract class MovieDatasource {
  Future<List<Movie>> getNowPlaying({int page = 1, String? region});

  Future<List<Movie>> getPopular({int page = 1, String? region});

  Future<List<Movie>> getTopRated({int page = 1, String? region});

  Future<List<Movie>> getUpcoming({int page = 1, String? region});

  Future<List<Movie>> searchMovies(String query, {int page = 1});

  Future<String?> getCertification(int movieId, String countryCode);

  Future<Movie> getMovieById(int id);
  Future<List<Movie>> getSimilar(int id, {int page = 1});

  Future<List<Video>> getYoutubeVideosById(int movieId);
  Future<List<Movie>> getAnime();
  Future<List<CastMember>> getCast(int movieId);
}
