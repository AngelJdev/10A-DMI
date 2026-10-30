import 'package:flutter/material.dart';

class MenuItem {
  const MenuItem(this.title, this.subtitle, this.path, this.icon, this.group);
  final String title, subtitle, path, group;
  final IconData icon;
}

const menuItems = [
  MenuItem(
    'Botones',
    'Variantes y acciones',
    '/buttons',
    Icons.smart_button_outlined,
    'Componentes',
  ),
  MenuItem(
    'Tarjetas',
    'Elevación, bordes e imágenes',
    '/cards',
    Icons.credit_card,
    'Componentes',
  ),
  MenuItem(
    'Indicadores de progreso',
    'Progreso determinado e indeterminado',
    '/progress',
    Icons.donut_large,
    'Componentes',
  ),
  MenuItem(
    'Notificaciones y diálogos',
    'Mensajes y confirmaciones',
    '/dialogs',
    Icons.notifications_outlined,
    'Componentes',
  ),
  MenuItem(
    'Animaciones',
    'Dimensiones, colores y bordes',
    '/animated',
    Icons.animation,
    'Interacción',
  ),
  MenuItem(
    'Controles',
    'Switch, radio y checkbox',
    '/controls',
    Icons.tune,
    'Interacción',
  ),
  MenuItem(
    'Tutorial',
    'Bienvenida en tres pasos',
    '/tutorial',
    Icons.swipe,
    'Interacción',
  ),
  MenuItem(
    'Scroll infinito',
    'Imágenes y Pull to Refresh',
    '/infinite',
    Icons.all_inclusive,
    'Interacción',
  ),
  MenuItem(
    'Contador',
    'Estado reactivo con Riverpod',
    '/counter',
    Icons.add_circle_outline,
    'Estado y tema',
  ),
  MenuItem(
    'Tema',
    'Colores y modo oscuro',
    '/theme',
    Icons.palette_outlined,
    'Estado y tema',
  ),
];
