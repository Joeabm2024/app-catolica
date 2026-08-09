// lib/features/oraciones/presentation/widgets/oracion_list_tile.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../domain/entities/oracion.dart';

class OracionListTile extends StatelessWidget {
  final Oracion oracion;
  final bool esFavorito;
  final VoidCallback onTap;

  const OracionListTile({
    super.key,
    required this.oracion,
    required this.esFavorito,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(oracion.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          OracionesConstants.etiquetaCategoria(oracion.categoria),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (esFavorito) const Icon(Icons.favorite, size: 18, color: AppColors.error),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
