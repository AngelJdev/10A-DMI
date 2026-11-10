import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/main.dart';
import 'package:practica06/presentation/widgets/movies/movies_slideshow.dart';
import 'package:practica06/infrastructure/mappers/movie_mapper.dart';
import 'package:practica06/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:practica06/presentation/providers/movies/movies_providers.dart';

void main() {
  testWidgets('El carrusel muestra tarjetas redondeadas y permite deslizar', (
    tester,
  ) async {
    dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test-key');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowPlayingMoviesProvider.overrideWith(
            (ref) => MoviesNotifier(
              fetchMoreMovies: ({int page = 1}) async => List.generate(
                8,
                (index) => MovieMapper.movieDBToEntity(
                  MovieDb.fromJson({
                    'id': index,
                    'title': 'Película $index',
                    'poster_path': '/poster.jpg',
                    'backdrop_path': '/backdrop.jpg',
                  }),
                ),
              ),
            ),
          ),
        ],
        child: const Practica06App(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cinemapedia'), findsOneWidget);
    expect(find.byKey(const ValueKey('carousel-indicator-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('carousel-indicator-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('carousel-indicator-2')), findsOneWidget);
    final dots = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(MoviesSlideshow),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(dots.length, 6);
    for (final dot in dots) {
      expect(dot.constraints!.maxWidth, 7);
      expect(dot.constraints!.maxHeight, 7);
      expect((dot.decoration as BoxDecoration).shape, BoxShape.circle);
    }
    Color? indicatorColor(int index) =>
        (tester
                    .widget<AnimatedContainer>(
                      find.descendant(
                        of: find.byKey(ValueKey('carousel-indicator-$index')),
                        matching: find.byType(AnimatedContainer),
                      ),
                    )
                    .decoration
                as BoxDecoration)
            .color;
    final selectedColor = Theme.of(tester.element(find.byType(PageView)))
        .colorScheme
        .primary;
    expect(indicatorColor(0), selectedColor);
    expect(indicatorColor(1), isNot(selectedColor));
    final carousel = tester.widget<PageView>(find.byType(PageView));
    expect(carousel.controller!.page! % 6, 0);
    final cards = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(PageView),
            matching: find.byType(Container),
          ),
        )
        .where((card) => card.foregroundDecoration is BoxDecoration);
    expect(cards, isNotEmpty);
    for (final card in cards) {
      expect(card.clipBehavior, Clip.antiAlias);
      expect(
        (card.decoration as BoxDecoration).borderRadius,
        BorderRadius.circular(20),
      );
      expect((card.foregroundDecoration as BoxDecoration).border, isNotNull);
    }
    await tester.tap(find.byKey(const ValueKey('carousel-indicator-2')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(carousel.controller!.page! % 6, 2);

    await tester.tap(find.byKey(const ValueKey('carousel-indicator-0')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(carousel.controller!.page! % 6, 0);

    await tester.drag(find.byType(PageView), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(carousel.controller!.page! % 6, 1);
    expect(indicatorColor(1), selectedColor);
    expect(indicatorColor(0), isNot(selectedColor));

    expect(find.byKey(const ValueKey('carousel-indicator-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('carousel-indicator-6')), findsNothing);
    final previous = find.byKey(const ValueKey('carousel-previous'));
    final next = find.byKey(const ValueKey('carousel-next'));
    Future<void> doubleTap(Finder target) async {
      await tester.tap(target);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tester.tap(next);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(carousel.controller!.page! % 6, 2);
    await tester.tap(previous);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(carousel.controller!.page! % 6, 1);

    await doubleTap(next);
    expect(carousel.controller!.page! % 6, 5);
    expect(indicatorColor(5), selectedColor);
    await doubleTap(previous);
    expect(carousel.controller!.page! % 6, 0);
    expect(indicatorColor(0), selectedColor);

    await doubleTap(
      find.byKey(
        ValueKey('carousel-movie-${carousel.controller!.page!.round()}'),
      ),
    );
    expect(carousel.controller!.page! % 6, 1);
    expect(indicatorColor(1), selectedColor);
  });
}
