// lib/shared/widgets/favorito_button.dart
//
// Reutilizable: hoy lo usa Cantos, y Biblia lo reutilizará tal cual
// cuando lleguemos a ese módulo (mismo patrón de favoritos por usuario).

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FavoritoButton extends StatelessWidget {
  final bool esFavorito;
  final VoidCallback onTap;

  const FavoritoButton({
    super.key,
    required this.esFavorito,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        esFavorito ? Icons.favorite : Icons.favorite_border,
        color: esFavorito ? AppColors.error : AppColors.textSecondary,
      ),
      tooltip: esFavorito ? 'Quitar de favoritos' : 'Guardar en favoritos',
    );
  }
}
