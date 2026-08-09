// lib/features/liturgia/presentation/widgets/color_liturgico_chip.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/liturgical_colors.dart';

class ColorLiturgicoChip extends StatelessWidget {
  final String colorLiturgico;
  final String tiempoLiturgico;

  const ColorLiturgicoChip({
    super.key,
    required this.colorLiturgico,
    required this.tiempoLiturgico,
  });

  @override
  Widget build(BuildContext context) {
    final info = LiturgicalColors.from(colorLiturgico);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: info.colorTexto),
          const SizedBox(width: 8),
          Text(
            tiempoLiturgico,
            style: TextStyle(
              color: info.colorTexto,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
