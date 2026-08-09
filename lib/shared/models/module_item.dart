// lib/shared/models/module_item.dart
//
// Vive en shared/ (no dentro de features/home) porque representa un
// concepto transversal: cualquier módulo de contenido futuro (Oraciones,
// Rosario, etc.) puede aparecer referenciado aquí sin crear una
// dependencia de core -> features.

import 'package:flutter/material.dart';

class ModuleItem {
  final String id;
  final String titulo;
  final IconData icono;
  final String ruta;

  const ModuleItem({
    required this.id,
    required this.titulo,
    required this.icono,
    required this.ruta,
  });
}
