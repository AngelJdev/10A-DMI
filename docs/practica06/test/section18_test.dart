import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/infrastructure/datasources/moviedb_datasource.dart';

class JsonAdapter implements HttpClientAdapter {
  JsonAdapter(this.data);
  final Map<String, dynamic> data;
  String? path;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() => dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test'));

  test('Videos de TMDB filtran otros sitios y claves inválidas y priorizan el tráiler oficial en español', () async {
    final adapter = JsonAdapter({
      'results': [
        {
          'id': 'en',
          'site': 'YouTube',
          'key': 'english_key',
          'type': 'Trailer',
          'official': true,
          'iso_639_1': 'en',
        },
        {
          'id': 'clip',
          'site': 'YouTube',
          'key': 'clip_key',
          'type': 'Clip',
          'iso_639_1': 'es',
        },
        {'id': 'vimeo', 'site': 'Vimeo', 'key': 'vimeo_key'},
        {'id': 'invalid', 'site': 'YouTube', 'key': 'https://invalid.example'},
        {
          'id': 'es',
          'site': 'YouTube',
          'key': 'spanish_key',
          'name': 'Tráiler oficial',
          'type': 'Trailer',
          'official': true,
          'iso_639_1': 'es',
          'published_at': '2026-10-01T12:00:00Z',
        },
        'not-a-video',
      ],
    });
    final datasource = MoviedbDatasource()..dio.httpClientAdapter = adapter;
    final videos = await datasource.getYoutubeVideosById(550);
    expect(adapter.path, '/movie/550/videos');
    expect(videos.map((video) => video.id), ['es', 'en', 'clip']);
    expect(videos.first.youtubeKey, 'spanish_key');
    expect(videos.first.publishedAt, DateTime.utc(2026, 10, 1, 12));
    expect(videos.last.publishedAt, isNull);
  });

  test('El detalle usa los nombres de los géneros y admite fecha de estreno ausente', () async {
    final adapter = JsonAdapter({
      'id': 550,
      'title': 'Película de prueba',
      'poster_path': '/poster.jpg',
      'genres': [
        {'id': 18, 'name': 'Drama'},
        {'id': 53, 'name': 'Suspenso'},
      ],
    });
    final datasource = MoviedbDatasource()..dio.httpClientAdapter = adapter;
    final movie = await datasource.getMovieById(550);
    expect(adapter.path, '/movie/550');
    expect(movie.genreIds, ['Drama', 'Suspenso']);
    expect(movie.releaseDate, isNull);
    expect(movie.backdropPath, 'https://image.tmdb.org/t/p/w500/poster.jpg');
  });
}
