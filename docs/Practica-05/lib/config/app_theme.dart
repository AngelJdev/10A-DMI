import 'package:flutter/material.dart';

const themeColors = <String, Color>{
  'Guinda': Color(0xFF963C45),
  'Índigo': Colors.indigo,
  'Verde': Colors.teal,
  'Naranja': Colors.deepOrange,
  'Violeta': Colors.purple,
};

class AppTheme {
  const AppTheme({this.colorIndex = 0, this.isDark = false});
  final int colorIndex;
  final bool isDark;
  AppTheme copyWith({int? colorIndex, bool? isDark}) => AppTheme(
    colorIndex: colorIndex ?? this.colorIndex,
    isDark: isDark ?? this.isDark,
  );
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColors.values.elementAt(colorIndex),
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}
