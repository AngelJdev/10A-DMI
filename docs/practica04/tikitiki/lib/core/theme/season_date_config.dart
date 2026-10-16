import 'season_theme.dart';

/// Punto único para probar las temporadas sin modificar la fecha del teléfono.
///
/// Cambia el valor, guarda y reinicia la aplicación. Ejemplos:
///
/// ```dart
/// final DateTime? simulatedSeasonDate = DateTime(2026, 10, 20); // Halloween
/// final DateTime? simulatedSeasonDate = DateTime(2026, 12, 20); // Navidad
/// final DateTime? simulatedSeasonDate = DateTime(2026, 2, 10);  // San Valentín
/// final DateTime? simulatedSeasonDate = DateTime(2026, 7, 10);  // Normal
/// ```
///
/// Déjalo en `null` para usar `DateTime.now()`, es decir, la fecha real del
/// dispositivo.
final DateTime? simulatedSeasonDate = DateTime(2026, 2, 10);

/// Calendario estacional centralizado. Los límites son inclusivos:
/// - Halloween: 15 de octubre al 5 de noviembre.
/// - Navidad: 10 de diciembre al 6 de enero.
/// - San Valentín: 1 al 14 de febrero.
/// - Normal: cualquier otra fecha.
Season seasonForDate(DateTime date) {
  final monthDay = date.month * 100 + date.day;

  if (monthDay >= 1015 && monthDay <= 1105) {
    return Season.halloween;
  }
  if (monthDay >= 1210 || monthDay <= 106) {
    return Season.christmas;
  }
  if (monthDay >= 201 && monthDay <= 214) {
    return Season.valentines;
  }
  return Season.normal;
}

/// Fecha efectiva que usa la app. Se expone para mostrarla en la interfaz y
/// para que la documentación coincida con la regla que se está ejecutando.
DateTime get effectiveSeasonDate => simulatedSeasonDate ?? DateTime.now();
