import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

import '../widgets/demo_scaffold.dart';

const slides = [
  (
    'Explora los widgets',
    'Descubre botones, tarjetas y componentes de Material Design 3.',
    'assets/images/tutorial_1.png',
  ),
  (
    'Experimenta',
    'Prueba controles, animaciones y una galería que sigue creciendo.',
    'assets/images/tutorial_2.png',
  ),
  (
    'Hazla tuya',
    'Cambia los colores y activa el modo oscuro desde la pantalla Tema.',
    'assets/images/tutorial_3.png',
  ),
];

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});
  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final controller = PageController();
  int page = 0;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void finish() => context.canPop() ? context.pop() : context.go('/');
  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Tutorial',
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: finish, child: const Text('Omitir')),
        ),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: (index) => setState(() => page = index),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Image.asset(slide.$3, height: 220, fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    FadeInRight(
                      key: ValueKey('$index-$page'),
                      child: Column(
                        children: [
                          Text(
                            slide.$1,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(slide.$2, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                '${page + 1} / ${slides.length}',
                semanticsLabel: 'Paso ${page + 1} de ${slides.length}',
              ),
              const Spacer(),
              if (page > 0)
                TextButton(
                  onPressed: () => controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Anterior'),
                ),
              FilledButton(
                onPressed: page == slides.length - 1
                    ? finish
                    : () => controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                child: Text(
                  page == slides.length - 1 ? 'Comenzar' : 'Siguiente',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
