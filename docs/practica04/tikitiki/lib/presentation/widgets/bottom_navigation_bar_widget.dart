import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/season_provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const BottomNavigationBarWidget({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(240),
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', 0, isSelected: selectedIndex == 0),
              _buildNavItem(Icons.search, 'Tendencias', 1, isSelected: selectedIndex == 1),
              _buildCreateButton(seasonTheme.primaryColor, seasonTheme.secondaryColor),
              _buildNavItem(Icons.chat_bubble_outline, 'Bandeja', 3, isSelected: selectedIndex == 3),
              _buildNavItem(Icons.person_outline, 'Perfil', 4, isSelected: selectedIndex == 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? Colors.white : Colors.white54,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(Color primaryColor, Color secondaryColor) {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [secondaryColor, primaryColor],
        ),
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
