class HumanFormats {
  static String number(double value) {
    for (final unit in [(1e9, 'B'), (1e6, 'M'), (1e3, 'K')]) {
      if (value.abs() >= unit.$1) {
        final text = (value / unit.$1)
            .toStringAsFixed(1)
            .replaceFirst(RegExp(r'\.0$'), '');
        return '$text${unit.$2}';
      }
    }
    return value.toStringAsFixed(0);
  }
}
