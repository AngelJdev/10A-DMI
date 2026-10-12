import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/video.dart';
import '../providers/season_provider.dart';

class VideoDescriptionWidget extends StatefulWidget {
  final Video video;

  const VideoDescriptionWidget({
    super.key,
    required this.video,
  });

  @override
  State<VideoDescriptionWidget> createState() => _VideoDescriptionWidgetState();
}

class _VideoDescriptionWidgetState extends State<VideoDescriptionWidget> {
  bool _isExpanded = false;
  final int _thresholdChars = 80;

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;
    final isLong = widget.video.descripcion.length > _thresholdChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre del autor y badge de fuente
        Row(
          children: [
            Text(
              widget.video.usuario,
              style: seasonTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
                shadows: const [
                  Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildSourceBadge(widget.video.source, seasonTheme.primaryColor),
          ],
        ),
        const SizedBox(height: 8),

        // Sección de descripción (Colapsada vs Expandida con Scroll Vertical)
        if (!isLong)
          Text(
            widget.video.descripcion,
            style: seasonTheme.bodyStyle.copyWith(
              fontSize: 13,
              color: Colors.white.withAlpha(240),
            ),
          )
        else if (!_isExpanded)
          // Vista truncada con botón "... más"
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${widget.video.descripcion.substring(0, _thresholdChars)}... ',
                style: seasonTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  color: Colors.white.withAlpha(240),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'más',
                    style: TextStyle(
                      color: seasonTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // Vista Expandida con DESPLAZAMIENTO VERTICAL
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(160),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: seasonTheme.primaryColor.withAlpha(100), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 120, // Altura máxima con scroll vertical
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          widget.video.descripcion,
                          style: seasonTheme.bodyStyle.copyWith(
                            fontSize: 13,
                            height: 1.35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Text(
                      'Ocultar',
                      style: TextStyle(
                        color: seasonTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // Canción y sonido
        Row(
          children: [
            Icon(seasonTheme.musicIcon, color: seasonTheme.primaryColor, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.video.cancion,
                style: seasonTheme.captionStyle.copyWith(
                  color: Colors.white.withAlpha(220),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceBadge(VideoSource source, Color primaryColor) {
    String label;
    Color badgeColor;
    IconData icon;

    switch (source) {
      case VideoSource.youtube:
        label = 'YouTube';
        badgeColor = Colors.redAccent;
        icon = Icons.play_arrow;
        break;
      case VideoSource.dailymotion:
        label = 'Dailymotion';
        badgeColor = Colors.blueAccent;
        icon = Icons.live_tv;
        break;
      case VideoSource.vimeo:
        label = 'Vimeo';
        badgeColor = Colors.tealAccent;
        icon = Icons.videocam;
        break;
      case VideoSource.local:
        label = 'Local Asset';
        badgeColor = primaryColor;
        icon = Icons.phone_android;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(180),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
