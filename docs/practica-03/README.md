# Práctica 03: Yes No App

Aplicación de chat Flutter con Anitta. Inicia con “Hola Anitta!” y “Clase de Cycling tienes?”, responde preguntas terminadas en `?` con varias frases de Sí/No/Tal vez y muestra el GIF correspondiente de yesno.wtf.

## Objetivo

Practicar una arquitectura Flutter por capas, estado reactivo, integración HTTP, pruebas con dobles y presentación de una conversación accesible y localizada.

## Comportamiento y API

Los mensajes se recortan antes de agregarse. Los vacíos se ignoran; los que no terminan en `?` solo aparecen en el chat. Para cada pregunta, la app sortea con pesos relativos `yes: 40`, `no: 40`, `maybe: 20`, envía una sola petición a `GET https://yesno.wtf/api?force=<respuesta>` y muestra el texto y GIF recibidos. Las consultas se encolan para conservar el orden. Errores de red o datos se presentan como mensajes en español sin imagen.

## Arquitectura

`presentation` gestiona pantalla, widgets y provider; `config` contiene tema y helpers; `infrastructure` valida y transforma el DTO de la API; `domain` define `Message` sin depender de Flutter. `Dio`, `Random`, pesos y reloj son inyectables para aislar las pruebas.

Los diagramas Mermaid editables se encuentran en [Docs/Architecture](Docs/Architecture/README.md).

## Dependencias

- Flutter SDK, Material 3 y `cupertino_icons: ^1.0.8`
- `dio: ^5.11.1`
- `provider: ^6.1.5+1`
- `flutter_test`, `integration_test` y `flutter_lints: ^6.0.0`

## Ejecutar

Desde esta carpeta:

```powershell
flutter pub get
flutter run
```

Se requiere conexión a internet para consultar la API y descargar el GIF. Los timeouts de conexión, envío y recepción son de 10 segundos.

## Pruebas

```powershell
flutter analyze
flutter test
```

Las pruebas unitarias y de widgets usan dobles y no requieren internet. La prueba real de integración está en `integration_test/chat_flow_test.dart`; requiere un emulador/dispositivo Android o iOS conectado, internet y acceso a yesno.wtf:

```powershell
flutter test integration_test/chat_flow_test.dart -d <device-id>
```

## Recursos pendientes y limitaciones

No se encontró `assets/images/me.jpg`. Por eso el avatar usa un icono neutro y no se configuró un icono personal para el launcher. Cuando el recurso se agregue, se puede declarar como asset y usarlo en el avatar/icono; no se descargó ni inventó una foto personal. La disponibilidad del servicio público yesno.wtf y sus GIF depende de la red.
