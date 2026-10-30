import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

class DialogsScreen extends StatelessWidget {
  const DialogsScreen({super.key});
  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Notificaciones y diálogos',
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FilledButton(
          onPressed: () => showMessage(context, '¡Hola desde SnackBar!'),
          child: const Text('Mostrar notificación'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('¿Confirmar acción?'),
                content: const Text(
                  'Puedes confirmar o cancelar esta demostración.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            );
            if (!context.mounted) return;
            showMessage(
              context,
              confirmed == true ? 'Acción confirmada' : 'Acción cancelada',
            );
          },
          child: const Text('Abrir diálogo'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'Widgets App',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.widgets),
            children: [
              const Text(
                'Práctica 05 · Flutter, Material 3, GoRouter y Riverpod.',
              ),
            ],
          ),
          child: const Text('Acerca de'),
        ),
      ],
    ),
  );
}

class AnimatedScreen extends StatefulWidget {
  const AnimatedScreen({super.key});
  @override
  State<AnimatedScreen> createState() => _AnimatedScreenState();
}

class _AnimatedScreenState extends State<AnimatedScreen> {
  final random = Random();
  double width = 120, height = 120, radius = 20;
  Color color = const Color(0xFF963C45);
  void changeShape() => setState(() {
    width = 60 + random.nextDouble() * 200;
    height = 60 + random.nextDouble() * 200;
    radius = random.nextDouble() * 100;
    color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  });
  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Animaciones',
    floatingActionButton: FloatingActionButton(
      onPressed: changeShape,
      tooltip: 'Cambiar forma',
      child: const Icon(Icons.play_arrow),
    ),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pulsa reproducir para cambiar tamaño, color y bordes.'),
        ),
        Expanded(
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

enum Transport { walking, bicycle, car }

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});
  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  bool notifications = true, breakfast = false, lunch = false;
  Transport transport = Transport.walking;
  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Controles',
    child: ListView(
      children: [
        SwitchListTile(
          title: const Text('Notificaciones'),
          value: notifications,
          onChanged: (value) => setState(() => notifications = value),
        ),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text('Medio de transporte'),
          subtitle: const Text('Selecciona una opción'),
          children: [
            RadioGroup<Transport>(
              groupValue: transport,
              onChanged: (value) {
                if (value != null) setState(() => transport = value);
              },
              child: Column(
                children: [
                  for (final option in Transport.values)
                    RadioListTile<Transport>(
                      value: option,
                      title: Text(switch (option) {
                        Transport.walking => 'A pie',
                        Transport.bicycle => 'Bicicleta',
                        Transport.car => 'Automóvil',
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Incluir desayuno'),
          value: breakfast,
          onChanged: (value) => setState(() => breakfast = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Incluir comida'),
          value: lunch,
          onChanged: (value) => setState(() => lunch = value ?? false),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Opciones de comida seleccionadas: ${(breakfast ? 1 : 0) + (lunch ? 1 : 0)}',
          ),
        ),
      ],
    ),
  );
}
