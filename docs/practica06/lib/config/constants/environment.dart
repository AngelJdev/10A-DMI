import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  const Environment._();

  static String get theMovieDbKey =>
      dotenv.env['THE_MOVIEDB_KEY'] ??
      dotenv.env['THE_MOVIE_DB_KEY'] ??
      'No hay API key';
}
