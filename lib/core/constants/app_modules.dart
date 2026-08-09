// lib/core/constants/app_modules.dart
//
// Lista estática de módulos del dashboard. Cuando activemos el documento
// remoto `configuracion_app/home` (Firestore), esta lista pasa a ser el
// fallback si el documento no existe o falla la lectura — no se elimina.

import 'package:flutter/material.dart';
import '../../shared/models/module_item.dart';

class AppModules {
  AppModules._();

  static const List<ModuleItem> modulos = [
    ModuleItem(
      id: 'liturgia',
      titulo: 'Liturgia Diaria',
      icono: Icons.wb_sunny_outlined,
      ruta: '/liturgia',
    ),
    ModuleItem(
      id: 'cantos',
      titulo: 'Cantos',
      icono: Icons.music_note_outlined,
      ruta: '/cantos',
    ),
    ModuleItem(
      id: 'oraciones',
      titulo: 'Oraciones',
      icono: Icons.volunteer_activism_outlined,
      ruta: '/oraciones',
    ),
    ModuleItem(
      id: 'rosario',
      titulo: 'Rosario',
      icono: Icons.circle_outlined,
      ruta: '/rosario',
    ),
    ModuleItem(
      id: 'santoral',
      titulo: 'Santo del Día',
      icono: Icons.star_outline,
      ruta: '/santoral',
    ),
  ];
}
