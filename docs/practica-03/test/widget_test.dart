import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/config/helpers/format_time_of_day.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/screens/chat/chat_screen.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';

final _sentAt = DateTime(2026, 9, 28, 0, 0);

class _FakeAnswerApi extends GetYesNoAnswer {
  _FakeAnswerApi({this.error});

  final YesNoException? error;
  int calls = 0;

  @override
  Future<YesNoModel> call() async {
    calls++;
    if (error != null) throw error!;
    return YesNoModel(
      answer: 'yes',
      forced: true,
      image: 'https://example.com/answer.gif',
    );
  }
}

class _QueuedAnswerApi extends GetYesNoAnswer {
  final requests = <Completer<YesNoModel>>[];

  @override
  Future<YesNoModel> call() {
    final request = Completer<YesNoModel>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  group('formatTimeOfDay', () {
    test('formats morning, afternoon, padded minutes, midnight and noon', () {
      expect(formatTimeOfDay(DateTime(2026, 1, 1, 9, 5)), '9:05 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 1, 1, 15, 9)), '3:09 p.m.');
      expect(formatTimeOfDay(DateTime(2026, 1, 1)), '12:00 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 1, 1, 12)), '12:00 p.m.');
    });
  });

  group('AnswerWeights', () {
    test('uses 40/40/20 defaults and supports single-option weights', () {
      const weights = AnswerWeights();
      expect([weights.yes, weights.no, weights.maybe], [40, 40, 20]);
      expect(
        const AnswerWeights(yes: 1, no: 0, maybe: 0).choose(Random(1)),
        'yes',
      );
      expect(
        const AnswerWeights(yes: 0, no: 1, maybe: 0).choose(Random(1)),
        'no',
      );
      expect(
        const AnswerWeights(yes: 0, no: 0, maybe: 1).choose(Random(1)),
        'maybe',
      );
    });

    test('approximates configured proportions over a seeded sample', () {
      const weights = AnswerWeights();
      final random = Random(42);
      final counts = {'yes': 0, 'no': 0, 'maybe': 0};
      for (var index = 0; index < 10000; index++) {
        counts.update(weights.choose(random), (value) => value + 1);
      }
      expect(counts['yes'], closeTo(4000, 180));
      expect(counts['no'], closeTo(4000, 180));
      expect(counts['maybe'], closeTo(2000, 140));
    });
  });

  group('YesNoModel', () {
    test('normalizes response and maps answer plus image into a message', () {
      final model = YesNoModel.fromJson({
        'answer': ' YES ',
        'forced': true,
        'image': 'https://example.com/yes.gif',
      });
      final message = model.toMessage(sentAt: _sentAt, random: Random(1));
      expect(model.answer, 'yes');
      expect(
        message.text,
        isIn(['Sí', '¡Claro que sí!', '¡De una!', 'Por supuesto', '¡Va!']),
      );
      expect(message.imageUrl, 'https://example.com/yes.gif');
      expect(message.fromWho, FromWho.hers);
      expect(message.sentAt, _sentAt);
    });

    test('rejects missing, empty and non-string answers', () {
      for (final json in [
        <String, dynamic>{},
        {'answer': ''},
        {'answer': '   '},
        {'answer': 42},
      ]) {
        expect(() => YesNoModel.fromJson(json), throwsFormatException);
      }
    });

    test('defaults invalid fields and maps unknown answers to maybe', () {
      final model = YesNoModel.fromJson({
        'answer': 'unexpected',
        'forced': 'true',
        'image': 12,
      });
      final message = model.toMessage(sentAt: _sentAt, random: Random(1));
      expect(model.forced, isFalse);
      expect(model.image, isEmpty);
      expect(
        message.text,
        isIn(['Tal vez', 'Quizá', 'Puede ser', 'No estoy segura', 'Depende']),
      );
      expect(message.imageUrl, isNull);
    });
  });

  group('ChatProvider', () {
    test('starts with expected messages and deterministic timestamps', () {
      final provider = ChatProvider(
        answerApi: _FakeAnswerApi(),
        clock: () => _sentAt,
        answerInitialQuestion: false,
      );
      expect(provider.messageList.map((message) => message.text), [
        'Hola Anitta!',
        'Clase de Cycling tienes?',
      ]);
      expect(
        provider.messageList.every((message) => message.sentAt == _sentAt),
        isTrue,
      );
      provider.dispose();
    });

    test('automatically answers the initial cycling question', () async {
      final api = _FakeAnswerApi();
      final provider = ChatProvider(
        answerApi: api,
        clock: () => _sentAt,
        responseRandom: Random(4),
      );
      expect(provider.messageList[2].isLoading, isTrue);
      await provider.pendingAnswers;
      expect(api.calls, 1);
      expect(
        provider.messageList.last.text,
        isIn(['Sí', '¡Claro que sí!', '¡De una!', 'Por supuesto', '¡Va!']),
      );
      provider.dispose();
    });

    test(
      'ignores blank entries and only requests an answer for questions',
      () async {
        final api = _FakeAnswerApi();
        final provider = ChatProvider(
          answerApi: api,
          clock: () => _sentAt,
          answerInitialQuestion: false,
        );
        final initialCount = provider.messageList.length;
        await provider.sendMessage('  ');
        await provider.sendMessage('Hola');
        expect(provider.messageList.length, initialCount + 1);
        expect(api.calls, 0);
        await provider.sendMessage('¿Sí?');
        expect(api.calls, 1);
        expect(
          provider.messageList.last.text,
          isIn(['Sí', '¡Claro que sí!', '¡De una!', 'Por supuesto', '¡Va!']),
        );
        provider.dispose();
      },
    );

    test('shows API errors as text without image', () async {
      final api = _FakeAnswerApi(error: const YesNoException('Sin conexión'));
      final provider = ChatProvider(
        answerApi: api,
        clock: () => _sentAt,
        answerInitialQuestion: false,
      );
      await provider.sendMessage('¿Pregunta?');
      expect(provider.messageList.last.text, 'Sin conexión');
      expect(provider.messageList.last.imageUrl, isNull);
      provider.dispose();
    });

    test(
      'serializes quick questions and keeps replies in their slots',
      () async {
        final api = _QueuedAnswerApi();
        final provider = ChatProvider(
          answerApi: api,
          clock: () => _sentAt,
          answerInitialQuestion: false,
        );
        final first = provider.sendMessage('Primera?');
        final second = provider.sendMessage('Segunda?');
        await Future<void>.delayed(Duration.zero);
        expect(api.requests, hasLength(1));

        api.requests.first.complete(
          const YesNoModel(
            answer: 'yes',
            forced: true,
            image: 'https://example.com/yes.gif',
          ),
        );
        await first;
        expect(api.requests, hasLength(2));
        api.requests.last.complete(
          const YesNoModel(
            answer: 'no',
            forced: true,
            image: 'https://example.com/no.gif',
          ),
        );
        await second;

        final texts = provider.messageList
            .map((message) => message.text)
            .toList();
        expect(texts.sublist(0, 3), [
          'Hola Anitta!',
          'Clase de Cycling tienes?',
          'Primera?',
        ]);
        expect(
          texts[3],
          isIn(['Sí', '¡Claro que sí!', '¡De una!', 'Por supuesto', '¡Va!']),
        );
        expect(texts[4], 'Segunda?');
        expect(texts[5], isIn(['No', 'Hoy no', 'Mejor no', 'No creo', 'Nel']));
        provider.dispose();
      },
    );
  });

  testWidgets('initial screen shows chat, composer and no layout exception', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      YesNoApp(
        chatProvider: ChatProvider(
          answerApi: _FakeAnswerApi(),
          clock: () => _sentAt,
          answerInitialQuestion: false,
        ),
      ),
    );
    expect(find.text('Anitta'), findsOneWidget);
    expect(find.text('Hola Anitta!'), findsOneWidget);
    expect(find.text('Clase de Cycling tienes?'), findsOneWidget);
    expect(
      find.text('Escribe y termina con "?" para que te responda'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('bubbles show text and shared timestamp placement', (
    tester,
  ) async {
    final mine = Message(
      text: 'Pregunta?',
      fromWho: FromWho.me,
      sentAt: _sentAt,
    );
    final hers = Message(
      text: 'Tal vez',
      fromWho: FromWho.hers,
      sentAt: _sentAt,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              MyMessageBubble(message: mine),
              HerMessageBubble(message: hers),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Pregunta?'), findsOneWidget);
    expect(find.text('Tal vez'), findsOneWidget);
    expect(find.text('12:00 a.m.'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reply bubble renders an optional network image', (tester) async {
    final reply = Message(
      text: 'Sí',
      fromWho: FromWho.hers,
      imageUrl: 'https://example.com/answer.gif',
      sentAt: _sentAt,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HerMessageBubble(message: reply)),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Sí'), findsOneWidget);
    expect(find.text('12:00 a.m.'), findsOneWidget);
  });

  testWidgets('send by enter keeps chat usable after submission', (
    tester,
  ) async {
    final provider = ChatProvider(
      answerApi: _FakeAnswerApi(),
      clock: () => _sentAt,
      answerInitialQuestion: false,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Pregunta sin respuesta');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Pregunta sin respuesta'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
