import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_router.dart';
import 'providers/app_providers.dart';

void main() => runApp(const ProviderScope(child: WidgetsDemoApp()));

class WidgetsDemoApp extends ConsumerWidget {
  const WidgetsDemoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Widgets App',
    debugShowCheckedModeBanner: false,
    routerConfig: ref.watch(routerProvider),
    theme: ref.watch(themeProvider).getTheme(),
  );
}
