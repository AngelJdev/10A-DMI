import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/presentation/providers/providers.dart';
import 'package:practica06/presentation/views/popular_view.dart';

import 'course_features_test.dart' show movie;

void main() {
  testWidgets(
    'Populares muestra Masonry en móvil y carga otra página al deslizar',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pages = <int>[];
      final notifier = MoviesNotifier(
        fetchMoreMovies: ({int page = 1}) async {
          pages.add(page);
          return page > 2
              ? []
              : List.generate(
                  20,
                  (index) => movie((page - 1) * 20 + index + 1),
                );
        },
      );
      await notifier.loadNextPage();
      final container = ProviderContainer(
        overrides: [popularMoviesProvider.overrideWith((ref) => notifier)],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: PopularView(onMovieTap: (_) {})),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MasonryGridView), findsOneWidget);
      await tester.fling(
        find.byType(MasonryGridView),
        const Offset(0, -5500),
        2000,
      );
      await tester.pumpAndSettle();
      expect(pages, contains(2));
      expect(pages.toSet().length, pages.length);
      expect(container.read(popularMoviesProvider).length, 40);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );
}
