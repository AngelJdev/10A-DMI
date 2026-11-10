import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/infrastructure/datasources/series_datasource.dart';

import 'section18_test.dart' show JsonAdapter;

void main() {
  test(
    'Catálogos y búsqueda usan TV y convierten nombre y primera emisión',
    () async {
      final adapter = JsonAdapter({
        'results': [
          {
            'id': 23,
            'name': 'Una serie',
            'original_name': 'A series',
            'first_air_date': '2020-02-03',
            'poster_path': '/series.jpg',
            'vote_average': 8.4,
          },
        ],
      });
      final datasource = SeriesDatasource(
        client: Dio()..httpClientAdapter = adapter,
      );
      final results = await datasource.getPopular(page: 2);
      expect(adapter.path, '/tv/popular');
      expect(results.single.title, 'Una serie');
      expect(results.single.mediaType, MediaType.series);
      expect(results.single.releaseDate, DateTime(2020, 2, 3));
      expect(results.single.location, '/series/23');
      await datasource.getNowPlaying();
      expect(adapter.path, '/tv/on_the_air');
      await datasource.getUpcoming();
      expect(adapter.path, '/tv/airing_today');
      await datasource.getTopRated();
      expect(adapter.path, '/tv/top_rated');
      await datasource.searchMovies('Una serie');
      expect(adapter.path, '/search/tv');
      await datasource.getSimilar(23);
      expect(adapter.path, '/tv/23/similar');
    },
  );

  test('Detalle de series incluye temporadas, episodios y géneros', () async {
    final adapter = JsonAdapter({
      'id': 23,
      'name': 'Una serie',
      'number_of_seasons': 4,
      'number_of_episodes': 32,
      'genres': [
        {'id': 18, 'name': 'Drama'},
      ],
      'poster_path': '/series.jpg',
    });
    final datasource = SeriesDatasource(
      client: Dio()..httpClientAdapter = adapter,
    );
    final result = await datasource.getMovieById(23);
    expect(adapter.path, '/tv/23');
    expect(result.seasons, 4);
    expect(result.episodes, 32);
    expect(result.genreIds, ['Drama']);
    expect(result.releaseDate, isNull);
  });

  test(
    'Clasificación, reparto y videos de series consultan sus endpoints propios',
    () async {
      final client = Dio();
      final datasource = SeriesDatasource(client: client);
      final ratings = JsonAdapter({
        'results': [
          {'iso_3166_1': 'MX', 'rating': 'B15'},
        ],
      });
      client.httpClientAdapter = ratings;
      expect(await datasource.getCertification(23, 'MX'), 'B15');
      expect(ratings.path, '/tv/23/content_ratings');
      final cast = JsonAdapter({
        'cast': [
          {'id': 2, 'name': 'Actriz', 'character': 'Protagonista'},
        ],
      });
      client.httpClientAdapter = cast;
      expect((await datasource.getCast(23)).single.name, 'Actriz');
      expect(cast.path, '/tv/23/credits');
      final videos = JsonAdapter({
        'results': [
          {'id': 'clip', 'site': 'YouTube', 'key': 'clip_key', 'type': 'Clip'},
          {
            'id': 'trailer',
            'site': 'YouTube',
            'key': 'trailer_key',
            'type': 'Trailer',
            'iso_639_1': 'es',
            'official': true,
          },
          {'id': 'vimeo', 'site': 'Vimeo', 'key': 'vimeo_key'},
        ],
      });
      client.httpClientAdapter = videos;
      final result = await datasource.getYoutubeVideosById(23);
      expect(videos.path, '/tv/23/videos');
      expect(result.map((v) => v.id), ['trailer', 'clip']);
    },
  );
}
