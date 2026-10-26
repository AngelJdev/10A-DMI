import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/main.dart';

void main() {
  testWidgets('La ruta inicial muestra la pantalla principal', (tester) async {
    dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test-key');

    await tester.pumpWidget(const Practica06App());
    await tester.pumpAndSettle();

    expect(find.text('Cinemapedia'), findsOneWidget);
    expect(find.text('test-key'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
