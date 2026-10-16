import 'package:flutter_test/flutter_test.dart';
import 'package:tikitiki/core/theme/season_date_config.dart';
import 'package:tikitiki/core/theme/season_theme.dart';

void main() {
  group('seasonForDate', () {
    test('Halloween incluye del 15 de octubre al 5 de noviembre', () {
      expect(seasonForDate(DateTime(2026, 10, 14)), Season.normal);
      expect(seasonForDate(DateTime(2026, 10, 15)), Season.halloween);
      expect(seasonForDate(DateTime(2026, 11, 5)), Season.halloween);
      expect(seasonForDate(DateTime(2026, 11, 6)), Season.normal);
    });

    test('Navidad cruza el cambio de año', () {
      expect(seasonForDate(DateTime(2026, 12, 9)), Season.normal);
      expect(seasonForDate(DateTime(2026, 12, 10)), Season.christmas);
      expect(seasonForDate(DateTime(2027, 1, 6)), Season.christmas);
      expect(seasonForDate(DateTime(2027, 1, 7)), Season.normal);
    });

    test('San Valentín incluye del 1 al 14 de febrero', () {
      expect(seasonForDate(DateTime(2026, 1, 31)), Season.normal);
      expect(seasonForDate(DateTime(2026, 2, 1)), Season.valentines);
      expect(seasonForDate(DateTime(2026, 2, 14)), Season.valentines);
      expect(seasonForDate(DateTime(2026, 2, 15)), Season.normal);
    });
  });
}
