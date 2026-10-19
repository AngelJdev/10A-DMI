import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/video.dart';
import '../providers/season_provider.dart';

/// Reproductor unificado nativo a pantalla completa sin interfaces de terceros.
/// Optimizado para evitar trabones: init una sola vez, pausa/resume ligero,
/// sin reinits innecesarios en didUpdateWidget.
class UnifiedVideoPlayer extends StatefulWidget {
  final Video video;
  final bool isMuted;
  final bool autoPlay;
  final VoidCallback? onDoubleTapLike;

  const UnifiedVideoPlayer({
    super.key,
    required this.video,
    this.isMuted = false,
    this.autoPlay = true,
    this.onDoubleTapLike,
  });

  @override
  State<UnifiedVideoPlayer> createState() => _UnifiedVideoPlayerState();
}

class _UnifiedVideoPlayerState extends State<UnifiedVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showPlayIcon = false;
  bool _showHeartAnim = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.autoPlay;
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant UnifiedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo ajusta mute sin reinicializar
    if (oldWidget.isMuted != widget.isMuted) {
      _applyMute();
    }

    // Solo pausa / reanuda — NO reinicializa el controller
    if (oldWidget.autoPlay != widget.autoPlay && _isInitialized) {
      if (widget.autoPlay) {
        _videoController?.play();
        if (mounted) setState(() => _isPlaying = true);
      } else {
        _videoController?.pause();
        if (mounted) setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _initPlayer() async {
    try {
      VideoPlayerController controller;

      if (widget.video.url.startsWith('assets/')) {
        controller = VideoPlayerController.asset(widget.video.url);
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.url),
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false,
            mixWithOthers: false,
          ),
          httpHeaders: const {
            'Connection': 'keep-alive',
          },
        );
      }

      // Guarda referencia antes de await para poder hacer dispose seguro
      _videoController = controller;

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);

      if (widget.autoPlay) {
        await controller.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = widget.autoPlay;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
        });
      }
    }
  }

  void _applyMute() {
    _videoController?.setVolume(widget.isMuted ? 0.0 : 1.0);
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    setState(() {
      _isPlaying = !_isPlaying;
      _showPlayIcon = true;
    });

    if (_isPlaying) {
      _videoController!.play();
    } else {
      _videoController!.pause();
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showPlayIcon = false);
    });
  }

  void _handleDoubleTap() {
    widget.onDoubleTapLike?.call();
    setState(() => _showHeartAnim = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartAnim = false);
    });
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;

    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.white30, size: 48),
              SizedBox(height: 8),
              Text(
                'No se pudo cargar el video',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
              SizedBox(height: 12),
              Text(
                'Cargando video...',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. VIDEO NATIVO A PANTALLA COMPLETA
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),

          // 2. Icono transitorio de Play/Pausa
          if (_showPlayIcon)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),

          // 3. Animación de like flotante acorde a la temporada.
          if (_showHeartAnim)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.3),
                duration: const Duration(milliseconds: 400),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      seasonTheme.likedIcon,
                      size: 90,
                      color: seasonTheme.primaryColor,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
