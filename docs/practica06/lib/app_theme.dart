import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static const brandColor = Color(0xff246bfd);

  static ThemeData lightTheme() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandColor,
      primary: brandColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xff246bfd),
      unselectedItemColor: Color(0xff777982),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
  );
}
