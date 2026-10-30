import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        tooltip: 'Volver',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      ),
    ),
    body: SafeArea(child: child),
    floatingActionButton: floatingActionButton,
  );
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(label: 'Cerrar', onPressed: () {}),
      ),
    );
}
