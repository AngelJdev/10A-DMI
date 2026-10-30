# Evidencias de funcionamiento

Capturas reales obtenidas en el emulador Android 17 (API 37) con `integration_test` el 30 de octubre de 2026.

- `01-inicio.png`: catálogo principal.
- `02-botones.png`: variantes de botones y notificación de una acción.
- `cards.png`: tarjetas con diferentes elevaciones.
- `progress.png`: indicadores determinados e indeterminados.
- `dialogs.png`: confirmación mediante AlertDialog.
- `animated.png`: contenedor después de cambiar su forma.
- `controls.png`: switch, radios, expansión y casillas.
- `tutorial.png`: bienvenida con imagen local.
- `infinite.png`: galería con imágenes remotas después de Pull to Refresh.
- `counter.png`: contador incrementado mediante Riverpod.
- `theme.png`: modo oscuro con color verde.

[verificacion.json](verificacion.json) registra las versiones, las comprobaciones aprobadas y la huella SHA-256 del APK release. Las imágenes de la galería muestran contenido remoto real; su disponibilidad depende de los servicios externos.

Para regenerarlas, conecta un dispositivo Android y ejecuta desde `docs/Practica-05`:

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
```

El controlador en `test_driver/integration_test.dart` guarda las capturas en esta carpeta. Ejecuta la compilación release después del recorrido, de forma secuencial.
