import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/demo_scaffold.dart';

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => DemoScaffold(
    title: 'Contador',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Número de pulsaciones'),
          Text(
            '${ref.watch(counterProvider)}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              IconButton(
                onPressed: () => ref.read(counterProvider.notifier).state--,
                tooltip: 'Disminuir',
                icon: const Icon(Icons.remove),
              ),
              OutlinedButton(
                onPressed: () => ref.read(counterProvider.notifier).state = 0,
                child: const Text('Reiniciar'),
              ),
              IconButton.filled(
                onPressed: () => ref.read(counterProvider.notifier).state++,
                tooltip: 'Incrementar',
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return DemoScaffold(
      title: 'Tema',
      child: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: theme.isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleDarkMode(),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Color principal'),
          ),
          RadioGroup<int>(
            groupValue: theme.colorIndex,
            onChanged: (index) {
              if (index != null) {
                ref.read(themeProvider.notifier).changeColor(index);
              }
            },
            child: Column(
              children: [
                for (var i = 0; i < themeColors.length; i++)
                  RadioListTile<int>(
                    value: i,
                    title: Text(themeColors.keys.elementAt(i)),
                    secondary: Icon(
                      Icons.circle,
                      color: themeColors.values.elementAt(i),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'El tema se aplica a todas las pantallas y se conserva durante esta sesión.',
            ),
          ),
        ],
      ),
    );
  }
}
