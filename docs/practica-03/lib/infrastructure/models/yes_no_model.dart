import 'dart:math';

import 'package:yes_no_app/domain/entities/message.dart';

class YesNoModel {
  const YesNoModel({
    required this.answer,
    required this.forced,
    required this.image,
  });

  final String answer;
  final bool forced;
  final String image;

  factory YesNoModel.fromJson(Map<String, dynamic> json) {
    final rawAnswer = json['answer'];
    if (rawAnswer is! String || rawAnswer.trim().isEmpty) {
      throw const FormatException('La respuesta recibida no es válida.');
    }

    return YesNoModel(
      answer: rawAnswer.trim().toLowerCase(),
      forced: json['forced'] is bool ? json['forced'] as bool : false,
      image: json['image'] is String ? (json['image'] as String).trim() : '',
    );
  }

  Message toMessage({required DateTime sentAt, Random? random}) {
    final chooser = random ?? Random();
    final responses = switch (answer) {
      'yes' => const [
        'Sí',
        '¡Claro que sí!',
        '¡De una!',
        'Por supuesto',
        '¡Va!',
      ],
      'no' => const ['No', 'Hoy no', 'Mejor no', 'No creo', 'Nel'],
      _ => const [
        'Tal vez',
        'Quizá',
        'Puede ser',
        'No estoy segura',
        'Depende',
      ],
    };
    final text = responses[chooser.nextInt(responses.length)];
    final uri = Uri.tryParse(image);
    final isValidImage =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    return Message(
      text: text,
      fromWho: FromWho.hers,
      imageUrl: isValidImage ? image : null,
      sentAt: sentAt,
    );
  }
}
