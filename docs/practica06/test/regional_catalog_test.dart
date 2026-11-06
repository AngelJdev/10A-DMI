import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/domain/entities/movie.dart';
import 'package:practica06/domain/entities/region_profile.dart';
import 'package:practica06/infrastructure/datasources/moviedb_datasource.dart';
import 'package:practica06/infrastructure/mappers/movie_mapper.dart';
import 'package:practica06/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:practica06/infrastructure/repositories/movie_repository_impl.dart';
import 'package:practica06/infrastructure/repositories/movies_repository_provider.dart';
import 'package:practica06/presentation/providers/movies/movies_providers.dart';
import 'package:practica06/presentation/screens/movies/home_screen.dart';

class RegionalRepository extends MovieRepositoryImpl {
  RegionalRepository() : super(datasource: MoviedbDatasource());
  final requests = <String>[];

  @override
  Future<List<Movie>> getNowPlaying({int page = 1, String? region}) async {
    requests.add(region!);
    return List.generate(
      8,
      (i) => MovieMapper.movieDBToEntity(
        MovieDb.fromJson({
          'id': region.hashCode + i,
          'title': '$region película $i',
          'poster_path': '/poster.jpg',
          'backdrop_path': '/backdrop.jpg',
        }),
      ),
    );
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1, String? region}) async => [];
  @override
  Future<List<Movie>> getPopular({int page = 1, String? region}) async => [];
  @override
  Future<List<Movie>> getTopRated({int page = 1, String? region}) async => [];
}

void main() {
  testWidgets('País cambia títulos y conserva transición al menos 3 segundos', (
    tester,
  ) async {
    dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test');
    final repository = RegionalRepository();
    final container = ProviderContainer(
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('MX película 0'), findsOneWidget);

    container.read(selectedRegionProvider.notifier).state = regionProfiles
        .firstWhere((r) => r.code == 'BR');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Mudando região…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('BR película 0'), findsOneWidget);
    expect(find.text('MX película 0'), findsNothing);
    expect(find.text('Mudando região…'), findsNothing);

    container.read(selectedRegionProvider.notifier).state = regionProfiles
        .firstWhere((r) => r.code == 'US');
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('US película 0'), findsOneWidget);
    expect(find.text('BR película 0'), findsNothing);
    expect(repository.requests, containsAllInOrder(['MX', 'BR', 'US']));
  });
}
