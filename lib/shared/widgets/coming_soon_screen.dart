// lib/shared/widgets/coming_soon_screen.dart
//
// Placeholder reutilizable para rutas de módulos que aún no se han
// desarrollado (Biblia, Oraciones, Rosario, Santoral, Liturgia). Cada uno
// se reemplaza por su pantalla real en su propio módulo, sin tocar el
// router más que cambiar el builder de esa ruta.

import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String titulo;

  const ComingSoonScreen({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Este módulo está en construcción. Muy pronto estará disponible.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
