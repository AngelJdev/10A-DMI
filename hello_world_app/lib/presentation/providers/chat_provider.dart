import 'package:flutter/material.dart';
import 'package:hello_world_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> messageList = [
    Message(text: 'Hola', fromWho: FromWho.mine),
    Message(text: 'Bienvenido a mi app', fromWho: FromWho.hers),
  ];

  void sendMessage(String text) {
    final newMessage = Message(text: text, fromWho: FromWho.mine);
    messageList.add(newMessage);
    notifyListeners();
  }
}
