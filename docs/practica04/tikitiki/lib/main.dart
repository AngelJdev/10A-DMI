import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitiki/presentation/providers/discover_provider.dart';

import 'config/app_theme.dart';
import 'presentation/screens/discover/discover_screen.dart' show DiscoverScreen;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiscoverProvider()..loadVideos()),
      ],
      child: MaterialApp(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().lightTheme,
        home: const DiscoverScreen(),
      ),
    );
  }
}
