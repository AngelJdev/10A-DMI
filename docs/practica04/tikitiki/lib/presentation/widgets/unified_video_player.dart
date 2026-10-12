import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/video.dart';

/// Reproductor unificado nativo a pantalla completa sin interfaces de terceros
/// (sin controles de YouTube, sin barras rojas ni marcas de agua).
/// Reproduce directamente tanto assets locales como streams de red MP4.
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
  bool _isPlaying = true;
  bool _showPlayIcon = false;
  bool _showHeartAnim = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant UnifiedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMuted != widget.isMuted) {
      _applyMute();
    }
    if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay) {
        _videoController?.play();
        _isPlaying = true;
      } else {
        _videoController?.pause();
        _isPlaying = false;
      }
    }
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.video.url.startsWith('assets/')) {
        _videoController = VideoPlayerController.asset(widget.video.url);
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.url),
        );
      }

      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(widget.isMuted ? 0.0 : 1.0);

      if (widget.autoPlay) {
        await _videoController!.play();
        _isPlaying = true;
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _applyMute() {
    _videoController?.setVolume(widget.isMuted ? 0.0 : 1.0);
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    if (_isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }

    setState(() {
      _isPlaying = !_isPlaying;
      _showPlayIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showPlayIcon = false;
        });
      }
    });
  }

  void _handleDoubleTap() {
    widget.onDoubleTapLike?.call();
    setState(() {
      _showHeartAnim = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showHeartAnim = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // 1. REPRODUCCIÓN NATIVA LIMPIA A PANTALLA COMPLETA (SOLO EL VIDEO)
          if (_videoController != null && _videoController!.value.isInitialized)
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
          if (_showPlayIcon && !_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 60, color: Colors.white70),
              ),
            ),

          // 3. Animación de corazón flotante al hacer doble tap
          if (_showHeartAnim)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.3),
                duration: const Duration(milliseconds: 400),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 90,
                      color: Color(0xFFFE2C55),
                      shadows: [
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
