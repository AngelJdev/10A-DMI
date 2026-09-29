import 'package:flutter/material.dart';

const _chatPrimary = Color(0xFF155E63);
const _chatSecondary = Color(0xFFFFC857);
const _chatBackground = Color(0xFFFFF8ED);
const _themeSeeds = [
  _chatPrimary,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  AppTheme({this.selectedColor = 0})
    : assert(selectedColor >= 0 && selectedColor < _themeSeeds.length);

  final int selectedColor;

  ThemeData theme() {
    final base = ColorScheme.fromSeed(seedColor: _themeSeeds[selectedColor]);
    final scheme = selectedColor == 0
        ? base.copyWith(
            primary: _chatPrimary,
            onPrimary: Colors.white,
            secondary: _chatSecondary,
            onSecondary: const Color(0xFF30250F),
            surface: _chatBackground,
            onSurface: const Color(0xFF243238),
          )
        : base;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: selectedColor == 0
          ? _chatBackground
          : scheme.surface,
      colorScheme: scheme,
    );
  }
}
