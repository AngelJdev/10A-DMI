import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:widgets_app/main.dart';
import 'package:widgets_app/config/app_router.dart';
import 'package:widgets_app/config/menu_items.dart';
import 'package:widgets_app/providers/app_providers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('recorrido Android de las diez demostraciones', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WidgetsDemoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('01-inicio');
    await tester.tap(find.text('Botones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elevated'));
    await tester.pumpAndSettle();
    expect(find.text('Acción realizada'), findsOneWidget);
    await binding.takeScreenshot('02-botones');
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    for (final item in menuItems.skip(1)) {
      router.go(item.path);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      if (item.path == '/counter') {
        await tester.tap(find.byTooltip('Incrementar'));
        await tester.pump();
        expect(container.read(counterProvider), 1);
      }
      if (item.path == '/theme') {
        await tester.tap(find.text('Modo oscuro'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Verde'));
        await tester.pumpAndSettle();
        expect(container.read(themeProvider).isDark, isTrue);
      }
      if (item.path == '/dialogs') {
        await tester.tap(find.text('Abrir diálogo'));
        await tester.pumpAndSettle();
      }
      if (item.path == '/animated') {
        await tester.tap(find.byTooltip('Cambiar forma'));
        await tester.pumpAndSettle();
      }
      if (item.path == '/infinite') {
        await tester.drag(find.byType(ListView), const Offset(0, 400));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Imagen 18'), findsOneWidget);
      }
      await binding.takeScreenshot(item.path.substring(1));
      if (item.path == '/dialogs') {
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();
        expect(find.text('Acción confirmada'), findsOneWidget);
      }
    }
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Explora Material 3'), findsOneWidget);
  });
}
