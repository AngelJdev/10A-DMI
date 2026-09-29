import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    GetYesNoAnswer? answerApi,
    DateTime Function()? clock,
    Random? responseRandom,
    bool answerInitialQuestion = true,
  }) : _answerApi = answerApi ?? GetYesNoAnswer(),
       _clock = clock ?? DateTime.now,
       _responseRandom = responseRandom ?? Random() {
    final initialTime = _now();
    messageList = [
      Message(text: 'Hola Anitta!', fromWho: FromWho.me, sentAt: initialTime),
      Message(
        text: 'Clase de Cycling tienes?',
        fromWho: FromWho.me,
        sentAt: initialTime,
      ),
    ];
    if (answerInitialQuestion) _queueAnswer();
  }

  final GetYesNoAnswer _answerApi;
  final DateTime Function() _clock;
  final Random _responseRandom;
  final ScrollController scrollController = ScrollController();
  late final List<Message> messageList;
  Future<void> _answerQueue = Future<void>.value();
  bool _disposed = false;

  Future<void> get pendingAnswers => _answerQueue;

  DateTime _now() => _clock().toLocal();

  Future<void> sendMessage(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return Future<void>.value();

    messageList.add(
      Message(text: cleanText, fromWho: FromWho.me, sentAt: _now()),
    );
    if (cleanText.endsWith('?')) {
      _queueAnswer();
    }
    notifyListeners();
    _scrollToBottom();
    return _answerQueue;
  }

  void _queueAnswer() {
    final answerIndex = messageList.length;
    messageList.add(
      Message(
        text: 'Anitta está preparando una respuesta',
        fromWho: FromWho.hers,
        sentAt: _now(),
        isLoading: true,
      ),
    );
    _answerQueue = _answerQueue.then((_) => _answerQuestion(answerIndex));
  }

  Future<void> _answerQuestion(int answerIndex) async {
    try {
      final answer = await _answerApi();
      messageList[answerIndex] = answer.toMessage(
        sentAt: _now(),
        random: _responseRandom,
      );
    } on YesNoException catch (error) {
      messageList[answerIndex] = Message(
        text: error.message,
        fromWho: FromWho.hers,
        sentAt: _now(),
      );
    } catch (_) {
      messageList[answerIndex] = Message(
        text: 'Ocurrió un error inesperado al consultar la respuesta.',
        fromWho: FromWho.hers,
        sentAt: _now(),
      );
    }
    if (_disposed) return;
    notifyListeners();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (_disposed || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _disposed = true;
    scrollController.dispose();
    super.dispose();
  }
}
