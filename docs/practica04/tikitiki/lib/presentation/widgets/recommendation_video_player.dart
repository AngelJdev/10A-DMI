import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/recommendation.dart';

/// Widget unificado que reproduce:
/// - YouTube: via youtube_player_flutter (iframe API)
/// - MP4 de red (TikTok/Reels demo): via video_player
class RecommendationVideoPlayer extends StatefulWidget {
  final Recommendation recommendation;
  final bool autoPlay;
  final bool looping;

  const RecommendationVideoPlayer({
    super.key,
    required this.recommendation,
    this.autoPlay = true,
    this.looping = true,
  });

  @override
  State<RecommendationVideoPlayer> createState() => _RecommendationVideoPlayerState();
}

class _RecommendationVideoPlayerState extends State<RecommendationVideoPlayer> {
  late final _PlayerType playerType;
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;
  bool _isPlaying = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _determinePlayerType();
    _initializePlayer();
  }

  void _determinePlayerType() {
    switch (widget.recommendation.source) {
      case VideoSource.youtube:
        playerType = _PlayerType.youtube;
      case VideoSource.tiktok:
      case VideoSource.reels:
        playerType = _PlayerType.networkMp4;
    }
  }

  Future<void> _initializePlayer() async {
    try {
      switch (playerType) {
        case _PlayerType.youtube:
          await _initYouTube();
        case _PlayerType.networkMp4:
          await _initNetworkMp4();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar el video';
        });
      }
    }
  }

  Future<void> _initYouTube() async {
    final videoId = widget.recommendation.youtubeVideoId;
    if (videoId == null) throw Exception('Video ID de YouTube no válido');

    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: widget.autoPlay,
      params: YoutubePlayerParams(
        loop: widget.looping,
        mute: false,
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
      ),
    );
  }

  Future<void> _initNetworkMp4() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.recommendation.videoUrl),
    );
    await _videoController!.initialize();
    _videoController!.setLooping(widget.looping);
    if (widget.autoPlay) {
      _videoController!.play();
      _isPlaying = true;
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (playerType == _PlayerType.youtube) {
        if (_isPlaying) {
          _youtubeController?.pauseVideo();
        } else {
          _youtubeController?.playVideo();
        }
      } else {
        if (_isPlaying) {
          _videoController?.pause();
        } else {
          _videoController?.play();
        }
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _handleDoubleTap() {
    // Like animation could be added here
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 60),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoPlayer(),
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white54),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    switch (playerType) {
      case _PlayerType.youtube:
        return YoutubePlayer(controller: _youtubeController!);
      case _PlayerType.networkMp4:
        return _videoController!.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white));
    }
  }
}

enum _PlayerType { youtube, networkMp4 }