// lib/features/cantos/presentation/widgets/canto_list_tile.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/cantos_constants.dart';
import '../../domain/entities/canto.dart';

class CantoListTile extends StatelessWidget {
  final Canto canto;
  final bool esFavorito;
  final VoidCallback onTap;

  const CantoListTile({
    super.key,
    required this.canto,
    required this.esFavorito,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tiempos = canto.tiemposLiturgicos
        .where((t) => t != 'todos')
        .map(CantosConstants.etiquetaTiempo)
        .join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(canto.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: tiempos.isNotEmpty
            ? Text(tiempos, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (esFavorito) const Icon(Icons.favorite, size: 18, color: AppColors.error),
            if (canto.pdfUrl != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.textSecondary),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
