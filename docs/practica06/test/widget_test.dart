import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica06/main.dart';

void main() {
  testWidgets('La ruta inicial muestra el marcador de la practica 06', (tester) async {
    await tester.pumpWidget(const Practica06App());
    await tester.pumpAndSettle();

    expect(find.byType(Placeholder), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
