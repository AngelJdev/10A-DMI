import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/component_screens.dart';
import '../screens/progress_screen.dart';
import '../screens/interaction_screens.dart';
import '../screens/tutorial_screen.dart';
import '../screens/infinite_screen.dart';
import '../screens/state_screens.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/buttons', builder: (_, _) => const ButtonsScreen()),
      GoRoute(path: '/cards', builder: (_, _) => const CardsScreen()),
      GoRoute(path: '/progress', builder: (_, _) => const ProgressScreen()),
      GoRoute(path: '/dialogs', builder: (_, _) => const DialogsScreen()),
      GoRoute(path: '/animated', builder: (_, _) => const AnimatedScreen()),
      GoRoute(path: '/controls', builder: (_, _) => const ControlsScreen()),
      GoRoute(path: '/tutorial', builder: (_, _) => const TutorialScreen()),
      GoRoute(path: '/infinite', builder: (_, _) => const InfiniteScreen()),
      GoRoute(path: '/counter', builder: (_, _) => const CounterScreen()),
      GoRoute(path: '/theme', builder: (_, _) => const ThemeScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Ir al inicio'),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
