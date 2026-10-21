import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: SafeArea(
          child: Placeholder(
            color: Color(0xFF90A4AE),
            strokeWidth: 1,
          ),
        ),
      ),
    ),
  ],
);
