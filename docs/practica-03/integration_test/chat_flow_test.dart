import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plain messages do not answer; a question returns one GIF', (
    tester,
  ) async {
    final provider = _integrationProvider();
    await tester.pumpWidget(YesNoApp(chatProvider: provider));
    expect(find.text('Anitta'), findsOneWidget);
    expect(find.text('Hola Anitta!'), findsOneWidget);
    expect(find.text('Clase de Cycling tienes?'), findsOneWidget);
    await _waitForAnswer(tester, provider, 3);
    expect(provider.messageList[2].imageUrl, isNotNull);
    final initialLength = provider.messageList.length;

    await tester.enterText(find.byType(TextField), 'Hola, qué tal');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.text('Hola, qué tal'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Anitta está preparando una respuesta'), findsNothing);
    expect(provider.messageList.length, initialLength + 1);

    await tester.enterText(find.byType(TextField), '¿Qué hora es?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.text('Anitta está preparando una respuesta'), findsOneWidget);
    await _waitForAnswer(tester, provider, initialLength + 3);
    expect(provider.messageList.last.imageUrl, isNotNull);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            [
              'Sí',
              '¡Claro que sí!',
              '¡De una!',
              'Por supuesto',
              '¡Va!',
              'No',
              'Hoy no',
              'Mejor no',
              'No creo',
              'Nel',
              'Tal vez',
              'Quizá',
              'Puede ser',
              'No estoy segura',
              'Depende',
            ].contains(widget.data),
      ),
      findsWidgets,
    );
  });

  testWidgets('question produces a localized answer, image and visible time', (
    tester,
  ) async {
    final provider = _integrationProvider();
    await tester.pumpWidget(YesNoApp(chatProvider: provider));
    await _waitForAnswer(tester, provider, 3);
    await tester.enterText(find.byType(TextField), '¿Hay lugar en Cycling?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await _waitForAnswer(tester, provider, 5);

    expect(find.text('¿Hay lugar en Cycling?'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            [
              'Sí',
              '¡Claro que sí!',
              '¡De una!',
              'Por supuesto',
              '¡Va!',
              'No',
              'Hoy no',
              'Mejor no',
              'No creo',
              'Nel',
              'Tal vez',
              'Quizá',
              'Puede ser',
              'No estoy segura',
              'Depende',
            ].contains(widget.data),
      ),
      findsWidgets,
    );
    expect(provider.messageList.last.imageUrl, isNotNull);
    expect(find.byType(Image), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d{1,2}:\d{2} [ap]\.m\.$').hasMatch(widget.data ?? ''),
      ),
      findsWidgets,
    );
    expect(find.text('9:03 a.m.'), findsOneWidget);
    expect(find.text('9:05 a.m.'), findsOneWidget);
  });
}

ChatProvider _integrationProvider() {
  final start = DateTime(2026, 9, 28, 9);
  var minute = 0;
  return ChatProvider(clock: () => start.add(Duration(minutes: minute++)));
}

Future<void> _waitForAnswer(
  WidgetTester tester,
  ChatProvider provider,
  int expectedMessageCount,
) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(seconds: 1));
    if (provider.messageList.length >= expectedMessageCount &&
        !provider.messageList[expectedMessageCount - 1].isLoading) {
      return;
    }
  }
}
