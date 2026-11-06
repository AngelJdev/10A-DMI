import 'package:flutter/material.dart';

import '../../localization/app_copy.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.onMenu, this.onSearch, this.accentColor});
  final VoidCallback? onMenu;
  final VoidCallback? onSearch;
  final Color? accentColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final copy = AppCopy.of(context);

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Color.alphaBlend(
          (accentColor ?? colors.primary).withValues(alpha: 0.055),
          colors.surface,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenu,
              tooltip: copy.text('openMenu'),
              icon: const Icon(Icons.menu_rounded),
            ),
            const SizedBox(width: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/branding/cinemapedia.png',
                width: 34,
                height: 34,
                semanticLabel: 'Logo de Cinemapedia',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('Cinemapedia', style: titleStyle)),
            IconButton(
              onPressed: onSearch,
              tooltip: copy.text('search'),
              icon: Icon(Icons.search, color: accentColor ?? colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
