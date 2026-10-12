import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/video.dart';
import '../providers/season_provider.dart';
import '../providers/video_feed_provider.dart';
import 'unified_video_player.dart';
import 'video_description_widget.dart';
import 'video_side_actions.dart';

class VideoPlayerItem extends StatelessWidget {
  final Video video;
  final bool isCurrentInFeed;

  const VideoPlayerItem({
    super.key,
    required this.video,
    this.isCurrentInFeed = true,
  });

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;
    final feedProvider = context.watch<VideoFeedProvider>();

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. REPRODUCTOR UNIFICADO DE VIDEO
          UnifiedVideoPlayer(
            video: video,
            isMuted: feedProvider.isMuted,
            autoPlay: isCurrentInFeed,
            onDoubleTapLike: () {
              if (!video.isLiked) {
                feedProvider.toggleLike(video);
              }
            },
          ),

          // 2. GRADIENTE SUPERIOR PARA NAVEGACIÓN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. GRADIENTE INFERIOR TEMÁTICO DE TEMPORADA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: seasonTheme.gradientOverlay,
                ),
              ),
            ),
          ),

          // 4. DESCRIPCIÓN E INFORMACIÓN DEL CREADOR (Lado inferior izquierdo)
          Positioned(
            bottom: 25,
            left: 16,
            right: 85, // Deja espacio holgado para los botones laterales
            child: VideoDescriptionWidget(video: video),
          ),

          // 5. COLUMNA LATERAL DE ACCIONES (Lado inferior derecho)
          Positioned(
            bottom: 25,
            right: 12,
            child: VideoSideActions(
              video: video,
              isMuted: feedProvider.isMuted,
              onToggleLike: () => feedProvider.toggleLike(video),
              onToggleFavorite: () => feedProvider.toggleFavorite(video),
              onToggleMute: () => feedProvider.toggleMute(),
            ),
          ),
        ],
      ),
    );
  }
}
