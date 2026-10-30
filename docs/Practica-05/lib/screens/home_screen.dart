import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/menu_items.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Widgets App')),
    drawer: const AppDrawer(),
    body: ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: menuItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explora Material 3',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca un componente, experimenta y personaliza tu experiencia.',
                  ),
                ],
              ),
            ),
          );
        }
        final item = menuItems[index - 1];
        return ListTile(
          leading: Icon(
            item.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(item.path),
        );
      },
    ),
  );
}
