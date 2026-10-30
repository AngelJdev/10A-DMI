import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Botones',
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMessage(context, 'Acci?n flotante'),
        tooltip: 'Acci?n flotante',
        child: const Icon(Icons.add),
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => showMessage(context, 'Acción realizada'),
              child: const Text('Elevated'),
            ),
            const ElevatedButton(
              onPressed: null,
              child: Text('Elevated Disabled'),
            ),
            ElevatedButton.icon(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.alarm),
              label: const Text('Elevated Icon'),
            ),
            FilledButton(
              onPressed: () => showMessage(context, 'Acción realizada'),
              child: const Text('Filled'),
            ),
            FilledButton.icon(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Filled Icon'),
            ),
            OutlinedButton(
              onPressed: () => showMessage(context, 'Acción realizada'),
              child: const Text('Outline'),
            ),
            OutlinedButton.icon(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.image_outlined),
              label: const Text('Outline Icon'),
            ),
            TextButton(
              onPressed: () => showMessage(context, 'Acción realizada'),
              child: const Text('Text'),
            ),
            TextButton.icon(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.image_outlined),
              label: const Text('Text Icon'),
            ),
            Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => showMessage(context, 'Botón personalizado'),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Material + InkWell'),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.apps),
              tooltip: 'Más opciones',
            ),
            IconButton.filled(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.playlist_add_check),
              tooltip: 'Lista',
            ),
          ],
        ),
      ),
    );
  }
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  static const _photos = [
    'https://images.unsplash.com/photo-1455390582262-044c6ad8a?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1000&q=80',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1000&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Tarjetas',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        children: [
          for (var elevation = 0; elevation <= 5; elevation++)
            _ElevationCard(elevation: elevation),
          for (var elevation = 0; elevation <= 1; elevation++)
            _ElevationCard(elevation: elevation, outlined: true),
          const Card.filled(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Superficie de color'),
            ),
          ),
          for (final photo in _photos) _PhotoCard(imageUrl: photo),
        ],
      ),
    );
  }
}

class _ElevationCard extends StatelessWidget {
  const _ElevationCard({required this.elevation, this.outlined = false});

  final int elevation;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: outlined ? 0 : elevation.toDouble(),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: outlined
            ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant)
            : BorderSide.none,
      ),
      child: SizedBox(
        height: 82,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Elevation $elevation${outlined ? ' - outline' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            IconButton(
              onPressed: () => showMessage(context, 'Acción realizada'),
              icon: const Icon(Icons.more_vert, size: 18),
              tooltip: 'Más opciones',
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: const Color(0xFFE8D9D4),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined, size: 36),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              child: IconButton(
                onPressed: () => showMessage(context, 'Acción realizada'),
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: 'Más opciones',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
