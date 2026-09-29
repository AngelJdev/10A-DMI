import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_time_label.dart';

class HerMessageBubble extends StatelessWidget {
  const HerMessageBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * .78,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 6),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message.text,
                    style: TextStyle(color: colors.onSecondary),
                  ),
                ),
                if (message.isLoading) ...[
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 190,
                    height: 4,
                    child: LinearProgressIndicator(),
                  ),
                ],
                if (message.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.imageUrl!,
                      width: 220,
                      height: 180,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const SizedBox(
                              width: 220,
                              height: 100,
                              child: Center(
                                child: Text(
                                  'Anitta está enviando una imagen',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                            width: 220,
                            height: 100,
                            child: Center(
                              child: Text(
                                'No se pudo cargar la imagen',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
                MessageTimeLabel(
                  sentAt: message.sentAt,
                  color: colors.onSecondary.withValues(alpha: .78),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
