// lib/features/liturgia/presentation/widgets/lectura_card.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/liturgia_del_dia.dart';

class LecturaCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final LecturaBiblica lectura;
  final bool inicialmenteExpandida;

  const LecturaCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.lectura,
    this.inicialmenteExpandida = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: inicialmenteExpandida,
          leading: Icon(icono, color: AppColors.primary),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            lectura.referencia,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lectura.texto,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
