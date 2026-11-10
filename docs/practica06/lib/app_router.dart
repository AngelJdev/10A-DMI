import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'domain/entities/movie.dart';
import 'presentation/screens/movies/home_screen.dart';
import 'presentation/screens/movies/movie_route_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/home'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeScreen(
        selectedIndex: navigationShell.currentIndex,
        navigationShell: navigationShell,
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: HomeScreen.name,
              pageBuilder: (context, state) => NoTransitionPage(
                child: HomeView(
                  key: const PageStorageKey('home-view'),
                  onMovieTap: (movie) =>
                      context.push(movie.location, extra: movie),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) => NoTransitionPage(
                child: CategoriesView(
                  key: const PageStorageKey('categories-view'),
                  onMovieTap: (movie) =>
                      context.push(movie.location, extra: movie),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              pageBuilder: (context, state) => NoTransitionPage(
                child: FavoritesView(
                  onMovieTap: (movie) =>
                      context.push(movie.location, extra: movie),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/popular', redirect: (_, _) => '/categories'),
    GoRoute(
      path: '/series/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return id == null || id <= 0
            ? const Scaffold(body: Center(child: Text('Serie no disponible')))
            : MovieRouteScreen(
                movieId: id,
                mediaType: MediaType.series,
                initialMovie: state.extra is Movie
                    ? state.extra as Movie
                    : null,
              );
      },
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return id == null || id <= 0
            ? const Scaffold(body: Center(child: Text('Película no válida')))
            : MovieRouteScreen(
                movieId: id,
                initialMovie: state.extra is Movie
                    ? state.extra as Movie
                    : null,
              );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Cinemapedia')),
    body: Center(
      child: TextButton(
        onPressed: () => context.go('/home'),
        child: const Text('Volver al inicio'),
      ),
    ),
  ),
);
