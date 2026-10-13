import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/season_provider.dart';
import 'season_selector_dialog.dart';

class TopNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const TopNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final seasonProvider = context.watch<SeasonProvider>();
    final seasonTheme = seasonProvider.currentTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // 🎨 Logo dinámico por temporada — cambia según la fecha detectada
            // (Halloween, Navidad, San Valentín o Normal)
            // Al tocar abre el selector de temporada para pruebas/documentación
            GestureDetector(
              onTap: () => SeasonSelectorDialog.show(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  seasonTheme.logoAsset,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Pestañas Centrales: Discover | For You | Favorites con amplio espaciado
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem(context, 'Discover', 0, seasonTheme.primaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '|',
                    style: TextStyle(color: Colors.white.withAlpha(40), fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  _buildTabItem(context, 'For You', 1, seasonTheme.primaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '|',
                    style: TextStyle(color: Colors.white.withAlpha(40), fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  _buildTabItem(context, 'Favorites', 2, seasonTheme.primaryColor),
                ],
              ),
            ),

            // Botón de audio temático (reproducir sonido de temporada)
            IconButton(
              icon: Icon(
                seasonProvider.soundEnabled ? Icons.graphic_eq_rounded : Icons.volume_off_rounded,
                color: seasonProvider.soundEnabled ? seasonTheme.accentColor : Colors.white54,
                size: 22,
              ),
              tooltip: 'Efecto de temporada',
              onPressed: () => seasonProvider.playSeasonAudio(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String title,
    int index,
    Color activeColor,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: isSelected ? 16 : 14,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: activeColor.withAlpha(160),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: isSelected ? 22 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
