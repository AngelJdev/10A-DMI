import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  const MessageFieldBox({super.key, required this.onValue});

  final ValueChanged<String> onValue;

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _submit() {
    final value = _textController.text;
    if (value.trim().isEmpty) return;
    widget.onValue(value);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(32),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: 'Escribe y termina con "?" para que te responda',
          enabledBorder: border,
          focusedBorder: border,
          filled: true,
          suffixIcon: IconButton(
            tooltip: 'Enviar mensaje',
            icon: const Icon(Icons.send_outlined),
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
