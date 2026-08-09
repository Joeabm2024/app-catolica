// lib/shared/widgets/filtro_chips.dart
//
// Reutilizable para cualquier filtro de selección única mostrado como
// chips horizontales scrolleables (tiempo litúrgico y momento de misa en
// Cantos; potencialmente útil en Biblia/Oraciones más adelante).

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FiltroChipOpcion {
  final String id;
  final String etiqueta;
  const FiltroChipOpcion(this.id, this.etiqueta);
}

class FiltroChips extends StatelessWidget {
  final List<FiltroChipOpcion> opciones;
  final String? seleccionado;
  final ValueChanged<String?> onChanged;

  const FiltroChips({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opciones.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opcion = opciones[index];
          final activo = seleccionado == opcion.id;
          return ChoiceChip(
            label: Text(opcion.etiqueta),
            selected: activo,
            onSelected: (_) => onChanged(activo ? null : opcion.id),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: activo ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: activo ? AppColors.primary : Colors.black12),
          );
        },
      ),
    );
  }
}
