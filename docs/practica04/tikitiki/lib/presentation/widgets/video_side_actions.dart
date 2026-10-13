import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/number_formats.dart';
import '../../domain/entities/video.dart';
import '../providers/season_provider.dart';
import 'comments_sheet.dart';

class VideoSideActions extends StatefulWidget {
  final Video video;
  final bool isMuted;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleMute;

  const VideoSideActions({
    super.key,
    required this.video,
    required this.isMuted,
    required this.onToggleLike,
    required this.onToggleFavorite,
    required this.onToggleMute,
  });

  @override
  State<VideoSideActions> createState() => _VideoSideActionsState();
}

class _VideoSideActionsState extends State<VideoSideActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _discAnimController;

  @override
  void initState() {
    super.initState();
    // Animación de rotación continua en bucle (Loop) para el disco de música
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _discAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Avatar del creador con borde estacional
        _buildAvatar(seasonTheme.primaryColor),
        const SizedBox(height: 18),

        // 2. Botón Me Gusta interactivo (+1 / -1 persistente con icono temático moderno)
        _buildActionButton(
          icon: widget.video.isLiked ? seasonTheme.likedIcon : seasonTheme.likeIcon,
          color: widget.video.isLiked ? seasonTheme.primaryColor : Colors.white,
          countText: NumberFormats.formatCount(widget.video.likes),
          onTap: widget.onToggleLike,
          badgeColor: widget.video.isLiked ? seasonTheme.primaryColor.withAlpha(50) : null,
          glowColor: widget.video.isLiked ? seasonTheme.primaryColor : null,
        ),
        const SizedBox(height: 18),

        // 3. Botón Comentarios INTERACTIVO (Abre la hoja de comentarios)
        _buildActionButton(
          icon: seasonTheme.commentIcon,
          color: Colors.white,
          countText: NumberFormats.formatCount(widget.video.comentarios),
          onTap: () {
            CommentsSheet.show(context, widget.video);
          },
        ),
        const SizedBox(height: 18),

        // 4. Botón Guardar / Favoritos (Moderno)
        _buildActionButton(
          icon: widget.video.isFavorite ? Icons.bookmark_rounded : seasonTheme.bookmarkIcon,
          color: widget.video.isFavorite ? seasonTheme.accentColor : Colors.white,
          countText: widget.video.isFavorite ? 'Guardado' : 'Guardar',
          onTap: widget.onToggleFavorite,
          badgeColor: widget.video.isFavorite ? seasonTheme.accentColor.withAlpha(50) : null,
        ),
        const SizedBox(height: 18),

        // 5. Botón de Mute / Unmute interactivo
        _buildActionButton(
          icon: widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: widget.isMuted ? Colors.redAccent : seasonTheme.secondaryColor,
          countText: widget.isMuted ? 'Silencio' : 'Audio',
          onTap: widget.onToggleMute,
        ),
        const SizedBox(height: 18),

        // 6. Disco de vinilo rotatorio estilizado (Loop)
        _buildVinylDisc(seasonTheme.primaryColor),
      ],
    );
  }

  Widget _buildAvatar(Color primaryColor) {
    return SizedBox(
      width: 48,
      height: 54,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: primaryColor.withAlpha(120), blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.video.thumbnailUrl != null
                    ? NetworkImage(widget.video.thumbnailUrl!)
                    : null,
                child: widget.video.thumbnailUrl == null
                    ? Text(
                        widget.video.usuario.isNotEmpty
                            ? widget.video.usuario.substring(1, 2).toUpperCase()
                            : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String countText,
    required VoidCallback onTap,
    Color? badgeColor,
    Color? glowColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (badgeColor ?? Colors.black.withAlpha(100)),
              boxShadow: glowColor != null
                  ? [
                      BoxShadow(
                        color: glowColor.withAlpha(120),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 3),
          Text(
            countText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylDisc(Color primaryColor) {
    return RotationTransition(
      turns: _discAnimController,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.black,
              Colors.grey[850]!,
              Colors.black,
              primaryColor.withAlpha(220),
            ],
            stops: const [0.2, 0.6, 0.8, 1.0],
          ),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(color: primaryColor.withAlpha(80), blurRadius: 6),
          ],
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
