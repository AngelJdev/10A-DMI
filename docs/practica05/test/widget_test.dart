// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:practica05/main.dart';

void main() {
  testWidgets('home navigates to buttons and cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter + Material 3'), findsOneWidget);
    await tester.tap(find.text('Botones'));
    await tester.pumpAndSettle();
    expect(find.text('Buttons Screen'), findsOneWidget);
    expect(find.text('Elevated'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tarjetas'));
    await tester.pumpAndSettle();
    expect(find.text('Cards Screen'), findsOneWidget);
    expect(find.text('Elevation 0'), findsOneWidget);
  });

  testWidgets('home opens progress indicators', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Progress Indicators'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Circular progress indicator'), findsOneWidget);
    expect(find.text('Circular + Linear indicators'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    final initialValue = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;
    await tester.pump(const Duration(milliseconds: 50));
    final nextValue = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;
    expect(nextValue - initialValue, closeTo(0.02, 0.001));
  });
}
