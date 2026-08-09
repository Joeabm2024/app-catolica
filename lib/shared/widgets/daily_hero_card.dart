// lib/shared/widgets/daily_hero_card.dart
//
// Placeholder de contenido: el texto real del evangelio/santo del día
// llega con el Módulo 5 (Liturgia Diaria). Por ahora muestra la fecha
// y un CTA que, cuando ese módulo exista, navegará a /liturgia.
//
// NOTA: se formatea la fecha en español a mano (sin el paquete `intl`)
// para evitar depender de initializeDateFormatting() en el arranque de
// la app solo por esta tarjeta — si más adelante el proyecto ya usa
// `intl` en otro módulo, esto se puede simplificar.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/spanish_date_formatter.dart';

class DailyHeroCard extends StatelessWidget {
  const DailyHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hoy = SpanishDateFormatter.longDate(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hoy,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            'Evangelio del día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Toca para leer la liturgia de hoy',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => context.push('/liturgia'),
              child: const Text('Leer más'),
            ),
          ),
        ],
      ),
    );
  }
}
