import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

void main() {
  runApp(const Practica06App());
}

class Practica06App extends StatelessWidget {
  const Practica06App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
    );
  }
}
