import 'package:flutter/material.dart';

import '../../localization/app_copy.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: activeColor,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: copy.text('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.category_outlined),
          activeIcon: const Icon(Icons.category),
          label: copy.text('categories'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_border),
          activeIcon: const Icon(Icons.favorite),
          label: copy.text('favorites'),
        ),
      ],
    );
  }
}
