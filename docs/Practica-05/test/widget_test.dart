import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgets_app/main.dart';
import 'package:widgets_app/config/app_router.dart';
import 'package:widgets_app/providers/app_providers.dart';
import 'package:widgets_app/screens/infinite_screen.dart';

Future<ProviderContainer> boot(WidgetTester tester, [String path = '/']) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(routerProvider).go(path);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const WidgetsDemoApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return container;
}

void main() {
  testWidgets('catálogo abre botones y permite volver', (tester) async {
    await boot(tester);
    expect(find.text('Explora Material 3'), findsOneWidget);
    await tester.tap(find.text('Botones'));
    await tester.pumpAndSettle();
    expect(find.text('Material + InkWell'), findsOneWidget);
    await tester.tap(find.text('Elevated'));
    await tester.pump();
    expect(find.text('Acción realizada'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Explora Material 3'), findsOneWidget);
  });
  testWidgets('drawer comparte todas las rutas del catálogo', (tester) async {
    await boot(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Tema'),
      300,
      scrollable: find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.widgetWithText(NavigationDrawerDestination, 'Tema'));
    await tester.pumpAndSettle();
    expect(find.text('Modo oscuro'), findsOneWidget);
  });
  testWidgets('contador conserva estado al salir y regresar', (tester) async {
    final container = await boot(tester, '/counter');
    await tester.tap(find.byTooltip('Incrementar'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    container.read(routerProvider).go('/');
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/counter');
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('Reiniciar'));
    await tester.pump();
    expect(container.read(counterProvider), 0);
  });
  testWidgets('tema cambia color y brillo sin reiniciar la navegación', (
    tester,
  ) async {
    final container = await boot(tester, '/theme');
    await tester.tap(find.text('Modo oscuro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verde'));
    await tester.pumpAndSettle();
    expect(container.read(themeProvider).isDark, isTrue);
    expect(container.read(themeProvider).colorIndex, 2);
    expect(
      Theme.of(tester.element(find.text('Modo oscuro'))).brightness,
      Brightness.dark,
    );
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/theme',
    );
  });
  for (final confirm in [false, true]) {
    testWidgets('diálogo ${confirm ? "confirma" : "cancela"}', (tester) async {
      await boot(tester, '/dialogs');
      await tester.tap(find.text('Abrir diálogo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(confirm ? 'Confirmar' : 'Cancelar'));
      await tester.pumpAndSettle();
      expect(
        find.text(confirm ? 'Acción confirmada' : 'Acción cancelada'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
  testWidgets('controles actualizan selección y checkbox', (tester) async {
    await boot(tester, '/controls');
    await tester.tap(find.text('Bicicleta'));
    await tester.tap(find.text('Incluir desayuno'));
    await tester.pumpAndSettle();
    expect(find.text('Opciones de comida seleccionadas: 1'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'Incluir desayuno'),
          )
          .value,
      isTrue,
    );
  });
  testWidgets('tutorial avanza, retrocede y finaliza', (tester) async {
    final container = await boot(tester, '/tutorial');
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.text('Anterior'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/',
    );
  });
  testWidgets('stream actualiza progreso y se libera al salir', (tester) async {
    final container = await boot(tester, '/progress');
    final indicators = find.byType(LinearProgressIndicator);
    expect(indicators, findsNWidgets(2));
    final before = tester
        .widget<LinearProgressIndicator>(indicators.last)
        .value!;
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<LinearProgressIndicator>(indicators.last).value!,
      greaterThan(before),
    );
    container.read(routerProvider).go('/');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('galería agrega un lote y refresca el contenido', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InfiniteScreen()));
    await tester.pump();
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.childrenDelegate.estimatedChildCount, 9);
    list.controller!.jumpTo(list.controller!.position.maxScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester
          .widget<ListView>(find.byType(ListView))
          .childrenDelegate
          .estimatedChildCount,
      17,
    );
    list.controller!.jumpTo(0);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester
          .widget<ListView>(find.byType(ListView))
          .childrenDelegate
          .estimatedChildCount,
      9,
    );
    expect(find.text('Imagen 26'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('galería permite cancelar una carga al desmontarse', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InfiniteScreen()));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
