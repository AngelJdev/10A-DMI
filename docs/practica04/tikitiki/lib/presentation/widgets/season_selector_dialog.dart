import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/season_theme.dart';
import '../../core/theme/season_date_config.dart';
import '../providers/season_provider.dart';

class SeasonSelectorDialog extends StatelessWidget {
  const SeasonSelectorDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SeasonSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonProvider = context.watch<SeasonProvider>();
    final currentSeason = seasonProvider.currentSeason;
    final currentTheme = seasonProvider.currentTheme;
    final effectiveDate = effectiveSeasonDate;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: currentTheme.primaryColor.withAlpha(150), width: 1.5),
      ),
      title: Row(
        children: [
          Icon(currentTheme.badgeIcon, color: currentTheme.primaryColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo Temporada',
              style: currentTheme.headingStyle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prueba y selecciona cualquier tema estacional. La preferencia se guardará en Local Storage:',
              style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildOption(
              context: context,
              title: '🎃 Halloween',
              subtitle: 'Octubre • Púrpura, Naranja, Creepster',
              season: Season.halloween,
              isSelected: !seasonProvider.isAutoDetected && currentSeason == Season.halloween,
              color: const Color(0xFFFF6B00),
            ),
            const SizedBox(height: 10),
            _buildOption(
              context: context,
              title: '🎄 Navidad',
              subtitle: 'Diciembre • Rojo, Pino, Mountains of Xmas',
              season: Season.christmas,
              isSelected: !seasonProvider.isAutoDetected && currentSeason == Season.christmas,
              color: const Color(0xFFE50914),
            ),
            const SizedBox(height: 10),
            _buildOption(
              context: context,
              title: '💝 San Valentín',
              subtitle: 'Febrero • Rosa, Pasión, Dancing Script',
              season: Season.valentines,
              isSelected: !seasonProvider.isAutoDetected && currentSeason == Season.valentines,
              color: const Color(0xFFFF2E93),
            ),
            const SizedBox(height: 10),
            _buildOption(
              context: context,
              title: '📱 Normal (TikTok)',
              subtitle: 'Estándar • Cyan, Rojo, Inter',
              season: Season.normal,
              isSelected: !seasonProvider.isAutoDetected && currentSeason == Season.normal,
              color: const Color(0xFF25F4EE),
            ),
            const Divider(color: Colors.white24, height: 24),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: seasonProvider.isAutoDetected ? Colors.white : Colors.white24,
                ),
              ),
              tileColor: seasonProvider.isAutoDetected
                  ? Colors.white.withAlpha(30)
                  : Colors.transparent,
              leading: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
              title: const Text(
                '🔄 Automático (Fecha del Dispositivo)',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                simulatedSeasonDate == null
                    ? 'Fecha del dispositivo: ${effectiveDate.day}/${effectiveDate.month}/${effectiveDate.year}'
                    : 'Fecha simulada: ${effectiveDate.day}/${effectiveDate.month}/${effectiveDate.year}',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              onTap: () {
                seasonProvider.forceSeason(null);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: TextStyle(color: currentTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Season season,
    required bool isSelected,
    required Color color,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected ? color.withAlpha(40) : Colors.white.withAlpha(10),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60, fontSize: 11),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      onTap: () {
        context.read<SeasonProvider>().forceSeason(season);
        Navigator.of(context).pop();
      },
    );
  }
}
