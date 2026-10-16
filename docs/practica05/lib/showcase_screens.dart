import 'dart:async';

import 'package:flutter/material.dart';

const _wine = Color(0xFF963C45);
const _paper = Color(0xFFF8F6F4);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter + Material 3')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _MenuTile(
            icon: Icons.smart_button_outlined,
            title: 'Botones',
            subtitle: 'Varios botones en Flutter',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ButtonsScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.credit_card_outlined,
            title: 'Tarjetas',
            subtitle: 'Un contenedor estilizado',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CardsScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.donut_large_outlined,
            title: 'Progress Indicators',
            subtitle: 'Indicadores de progreso en Flutter',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProgressIndicatorsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: _wine, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: _wine),
      onTap: onTap,
    );
  }
}

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            const ElevatedButton(
              onPressed: null,
              child: Text('Elevated Disabled'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.alarm),
              label: const Text('Elevated Icon'),
            ),
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Filled Icon'),
            ),
            OutlinedButton(onPressed: () {}, child: const Text('Outline')),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_outlined),
              label: const Text('Outline Icon'),
            ),
            TextButton(onPressed: () {}, child: const Text('Text')),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_outlined),
              label: const Text('Text Icon'),
            ),
            FilledButton(onPressed: () {}, child: const Text('Hola Mundo')),
            IconButton.filledTonal(
              onPressed: () {},
              icon: const Icon(Icons.apps),
              tooltip: 'Más opciones',
            ),
            IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.playlist_add_check),
              tooltip: 'Lista',
            ),
          ],
        ),
      ),
      floatingActionButton: _BackButton(
        onPressed: () => Navigator.pop(context),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cards Screen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        children: [
          for (var elevation = 0; elevation <= 5; elevation++)
            _ElevationCard(elevation: elevation),
          for (var elevation = 0; elevation <= 1; elevation++)
            _ElevationCard(elevation: elevation, outlined: true),
          for (final photo in _photos) _PhotoCard(imageUrl: photo),
        ],
      ),
    );
  }
}

class ProgressIndicatorsScreen extends StatefulWidget {
  const ProgressIndicatorsScreen({super.key});

  @override
  State<ProgressIndicatorsScreen> createState() =>
      _ProgressIndicatorsScreenState();
}

class _ProgressIndicatorsScreenState extends State<ProgressIndicatorsScreen> {
  late final Timer _progressTimer;
  int _progressPercent = 0;

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        _progressPercent = _progressPercent >= 100 ? 0 : _progressPercent + 2;
      });
    });
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Indicators')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            Text(
              'Circular progress indicator',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: primary),
            const SizedBox(height: 28),
            Text(
              'Circular + Linear indicators',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircularProgressIndicator(color: primary),
                const SizedBox(width: 14),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _progressPercent / 100,
                    minHeight: 4,
                    color: primary,
                    backgroundColor: primary.withValues(alpha: 0.16),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      color: _paper,
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
              onPressed: () {},
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
              color: _paper.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              child: IconButton(
                onPressed: () {},
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      tooltip: 'Volver',
      child: const Icon(Icons.arrow_back_ios_new, size: 16),
    );
  }
}
