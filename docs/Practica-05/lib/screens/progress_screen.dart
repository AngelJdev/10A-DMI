import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final Stream<double> progress = Stream.periodic(
    const Duration(milliseconds: 100),
    (tick) => ((tick + 1) % 101) / 100,
  );
  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Indicadores de progreso',
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Indeterminados'),
        const SizedBox(height: 24),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 24),
        const LinearProgressIndicator(),
        const SizedBox(height: 40),
        const Text('Determinados · Stream.periodic'),
        const SizedBox(height: 24),
        StreamBuilder<double>(
          stream: progress,
          initialData: 0,
          builder: (context, snapshot) {
            final value = snapshot.data ?? 0;
            return Column(
              children: [
                CircularProgressIndicator(value: value),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: value),
                const SizedBox(height: 16),
                Text('${(value * 100).round()} %'),
              ],
            );
          },
        ),
      ],
    ),
  );
}
