import 'package:flutter/material.dart';
import 'package:hello_world_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:hello_world_app/presentation/widgets/chat/my_message_bubble.dart';
import 'package:hello_world_app/presentation/widgets/shared/message_field_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
    {'text': '¿Cómo estás?', 'isMine': true},
    {'text': 'Sí', 'isMine': false},
  ];

  final ScrollController scrollController = ScrollController();

  void _handleSendMessage(String value) {
    setState(() {
      messages.add({'text': value, 'isMine': true});
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=47',
            ),
          ),
        ),
        title: const Text(
          'Nicky Nicole',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return message['isMine']
                        ? MyMessageBubble(message: message['text'])
                        : HerMessageBubble(message: message['text']);
                  },
                ),
              ),
              MessageFieldBox(onValue: _handleSendMessage),
            ],
          ),
        ),
      ),
    );
  }
}
