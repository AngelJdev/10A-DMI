class NumberFormats {
  /// Formatea un conteo numérico. A partir de 10,000 (10K) se utiliza 'K',
  /// antes de 10K se muestra el número exacto (ej. 4899, 4900, 9999).
  /// A partir de 1,000,000 se utiliza 'M'.
  static String formatCount(int number) {
    if (number < 10000) {
      return number.toString();
    } else if (number < 1000000) {
      double k = number / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    } else {
      double m = number / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
  }
}
