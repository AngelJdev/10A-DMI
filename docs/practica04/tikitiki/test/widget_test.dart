import 'package:flutter_test/flutter_test.dart';
import 'package:tikitiki/core/utils/number_formats.dart';

void main() {
  group('NumberFormats.formatCount', () {
    test('Debe devolver el número exacto si es menor a 10,000 (10K)', () {
      expect(NumberFormats.formatCount(999), '999');
      expect(NumberFormats.formatCount(4899), '4899');
      expect(NumberFormats.formatCount(4900), '4900');
      expect(NumberFormats.formatCount(9999), '9999');
    });

    test('Debe formatear en "K" (miles) a partir de 10,000 (10K) y menor a 1 millón', () {
      expect(NumberFormats.formatCount(10000), '10K');
      expect(NumberFormats.formatCount(12500), '12.5K');
      expect(NumberFormats.formatCount(100000), '100K');
    });

    test('Debe formatear en "M" (millones) si es igual o mayor a 1 millón', () {
      expect(NumberFormats.formatCount(1000000), '1M');
      expect(NumberFormats.formatCount(1200000), '1.2M');
    });
  });
}
