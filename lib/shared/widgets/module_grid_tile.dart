// lib/shared/widgets/module_grid_tile.dart

import 'package:flutter/material.dart';
import '../models/module_item.dart';
import '../../core/constants/app_colors.dart';

class ModuleGridTile extends StatelessWidget {
  final ModuleItem modulo;
  final VoidCallback onTap;

  const ModuleGridTile({super.key, required this.modulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(modulo.icono, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              modulo.titulo,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
