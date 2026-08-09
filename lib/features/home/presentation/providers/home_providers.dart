// lib/features/home/presentation/providers/home_providers.dart
//
// Este módulo no necesita datasources/repositorios propios todavía —
// consume directamente authStateProvider y loginControllerProvider del
// Módulo 1. Este archivo existe como punto único de extensión para cuando
// agreguemos `configuracion_app/home` (lista de módulos remota) más adelante.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_modules.dart';
import '../../../../shared/models/module_item.dart';

/// Hoy retorna la lista estática de core/constants/app_modules.dart.
/// El día que se lea `configuracion_app/home` desde Firestore, solo se
/// cambia la implementación de este provider — nada más en la UI cambia.
final dashboardModulesProvider = Provider<List<ModuleItem>>((ref) {
  return AppModules.modulos;
});
