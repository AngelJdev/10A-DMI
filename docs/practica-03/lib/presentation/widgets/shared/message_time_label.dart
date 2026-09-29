import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/format_time_of_day.dart';

class MessageTimeLabel extends StatelessWidget {
  const MessageTimeLabel({
    super.key,
    required this.sentAt,
    required this.color,
  });

  final DateTime sentAt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        formatTimeOfDay(sentAt),
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
