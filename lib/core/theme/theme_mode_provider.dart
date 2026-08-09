// lib/core/theme/theme_mode_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// ThemeMode reactivo. Arranca en `system` y, en cuanto authStateProvider
/// resuelve el usuario, se ajusta a su preferencia guardada
/// (usuarios/{uid}.configuracion.temaOscuro). PreferenciasScreen puede
/// sobreescribirlo en caliente llamando a `ref.read(themeModeProvider.notifier).set(...)`.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Se re-ejecuta cada vez que cambia authStateProvider (login/logout),
    // así el tema se ajusta a la preferencia del usuario que inició sesión.
    final authState = ref.watch(authStateProvider);
    final temaOscuro = authState.value?.preferencias.temaOscuro;
    if (temaOscuro == null) return ThemeMode.system;
    return temaOscuro ? ThemeMode.dark : ThemeMode.light;
  }

  /// Cambio manual desde PreferenciasScreen (antes de que se confirme la
  /// escritura en Firestore, para que la UI responda al instante).
  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
