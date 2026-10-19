import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme/season_theme.dart';
import '../../core/theme/season_date_config.dart';
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

    if (simulatedSeasonDate != null) {
      _isAutoDetected = true;
      _detectSeasonByDate();
    } else if (savedSeason != null) {
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
    await _updateLauncherIcon();
    if (_soundEnabled) {
      await playSeasonAudio();
    }
  }

  void _detectSeasonByDate() {
    _currentSeason = seasonForDate(effectiveSeasonDate);
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
    await _updateLauncherIcon();

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

  Future<void> _updateLauncherIcon() async {
    try {
      await const MethodChannel('com.tikitiki/season_launcher')
          .invokeMethod<void>('setSeason', _currentSeason.name);
    } catch (_) {
      // Esta plataforma no admite íconos dinámicos del lanzador.
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
