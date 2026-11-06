import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import 'app_theme.dart';
import 'presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: Practica06App()));
}

class Practica06App extends ConsumerWidget {
  const Practica06App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeParts = ref.watch(selectedRegionProvider).locale.split('-');
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      locale: Locale(localeParts.first, localeParts.last),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es', 'SV'),
        Locale('en', 'US'),
        Locale('en', 'AU'),
        Locale('pt', 'BR'),
        Locale('de', 'DE'),
        Locale('ja', 'JP'),
        Locale('fr', 'CD'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
