import 'package:flutter_riverpod/legacy.dart';

import '../config/app_theme.dart';

final counterProvider = StateProvider<int>((ref) => 0);
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(const AppTheme());
  void toggleDarkMode() => state = state.copyWith(isDark: !state.isDark);
  void changeColor(int index) {
    if (index >= 0 && index < themeColors.length) {
      state = state.copyWith(colorIndex: index);
    }
  }
}
