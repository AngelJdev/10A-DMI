import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/menu_items.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) => NavigationDrawer(
    selectedIndex: null,
    onDestinationSelected: (index) {
      Navigator.of(context).pop();
      context.push(menuItems[index].path);
    },
    children: [
      const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Widgets App', style: TextStyle(fontSize: 24)),
      ),
      for (var i = 0; i < menuItems.length; i++) ...[
        if (i == 0 || menuItems[i].group != menuItems[i - 1].group)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(menuItems[i].group),
          ),
        NavigationDrawerDestination(
          icon: Icon(menuItems[i].icon),
          label: SizedBox(
            width: 180,
            child: Text(
              menuItems[i].title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ],
  );
}
