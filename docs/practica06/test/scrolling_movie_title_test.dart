import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/presentation/widgets/shared/scrolling_movie_title.dart';

void main() {
  Widget host(String title) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 220,
          child: ScrollingMovieTitle(
            title: title,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    ),
  );

  testWidgets('Título corto centrado y con altura de una línea', (
    tester,
  ) async {
    await tester.pumpWidget(host('Coco'));
    final text = find.text('Coco');
    final container = find.byType(ScrollingMovieTitle);
    expect(
      tester.getCenter(text).dx,
      closeTo(tester.getCenter(container).dx, 0.1),
    );
    expect(tester.getSize(container).height, lessThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Título largo se desplaza automáticamente sin recortarlo con puntos',
    (tester) async {
      const title = 'La Leyenda de los Chaneques y una aventura extraordinaria';
      await tester.pumpWidget(host(title));
      await tester.pump(const Duration(milliseconds: 100));
      final first = tester.getTopLeft(find.text(title).first).dx;
      await tester.pump(const Duration(seconds: 3));
      final later = tester.getTopLeft(find.text(title).first).dx;
      expect(later, lessThan(first));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
