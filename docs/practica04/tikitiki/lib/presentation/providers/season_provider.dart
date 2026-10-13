import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme/season_theme.dart';
import '../../core/utils/storage_service.dart';

class SeasonProvider extends ChangeNotifier {
  Season _currentSeason = Season.normal;
  bool _isAutoDetected = true;
  bool _soundEnabled = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  SeasonProvider() {
    _initSeason();
  }

  Season get currentSeason => _currentSeason;
  SeasonTheme get currentTheme => SeasonTheme.fromSeason(_currentSeason);
  bool get isAutoDetected => _isAutoDetected;
  bool get soundEnabled => _soundEnabled;

  Future<void> _initSeason() async {
    final storage = await StorageService.getInstance();
    final savedSeason = storage.getSavedSeason();

    if (savedSeason != null) {
      _isAutoDetected = false;
      switch (savedSeason.toLowerCase()) {
        case 'halloween':
          _currentSeason = Season.halloween;
          break;
        case 'christmas':
          _currentSeason = Season.christmas;
          break;
        case 'valentines':
          _currentSeason = Season.valentines;
          break;
        default:
          _currentSeason = Season.normal;
      }
    } else {
      _isAutoDetected = true;
      _detectSeasonByDate();
    }
    notifyListeners();
  }

  void _detectSeasonByDate() {
    // ─────────────────────────────────────────────────────────────────────────
    // 🔧 VARIABLE DE SIMULACIÓN — Para cambiar la fecha en pruebas/demostración:
    //    Cambia `simulatedDate` a una fecha específica y reinicia la app.
    //    Pon `null` para que use la fecha real del dispositivo.
    //
    //    Ejemplos para pruebas:
    //      DateTime(2026, 10, 20)  → Halloween  🎃
    //      DateTime(2026, 12, 15)  → Navidad    🎄
    //      DateTime(2026, 2, 10)   → San Valentín ❤️
    //      null                    → Fecha real del dispositivo
    // ─────────────────────────────────────────────────────────────────────────
    const DateTime? simulatedDate = null; // <-- CAMBIA AQUÍ PARA SIMULAR
    // ─────────────────────────────────────────────────────────────────────────

    final now = simulatedDate ?? DateTime.now();
    final month = now.month;
    final day = now.day;

    // 🎃 Halloween / Día de Muertos: 15 oct → 31 oct
    if (month == 10 && day >= 15) {
      _currentSeason = Season.halloween;
    }
    // 🎄 Navidad: 10 dic → 31 dic
    else if (month == 12 && day >= 10) {
      _currentSeason = Season.christmas;
    }
    // ❤️ San Valentín: 1 feb → 14 feb
    else if (month == 2 && day <= 14) {
      _currentSeason = Season.valentines;
    }
    // 🕷️ Pre-Halloween (atmosférico): 1 oct → 14 oct
    else if (month == 10) {
      _currentSeason = Season.halloween;
    }
    // Resto del año → Normal
    else {
      _currentSeason = Season.normal;
    }
  }

  /// Permite cambiar forzadamente la temporada para fines de prueba
  /// y la almacena en el Local Storage (SharedPreferences).
  /// Si se pasa `null`, restaura la detección automática por fecha.
  Future<void> forceSeason(Season? season) async {
    final storage = await StorageService.getInstance();

    if (season == null) {
      _isAutoDetected = true;
      _detectSeasonByDate();
      await storage.saveSeason(null);
    } else {
      _isAutoDetected = false;
      _currentSeason = season;
      await storage.saveSeason(season.name);
    }

    notifyListeners();

    // Reproducir audio temático de temporada si está habilitado el sonido
    if (_soundEnabled) {
      playSeasonAudio();
    }
  }

  Future<void> playSeasonAudio() async {
    try {
      final theme = currentTheme;
      // Audio asset path sin el prefijo 'assets/' para audioplayers AssetSource
      final relativePath = theme.audioAsset.replaceFirst('assets/', '');
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relativePath));
    } catch (_) {
      // Ignorar si el dispositivo no soporta salida de audio en este momento
    }
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    if (!_soundEnabled) {
      _audioPlayer.stop();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
