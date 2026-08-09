// lib/features/perfil/presentation/screens/preferencias_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/models/user_preferences.dart';
import '../providers/perfil_providers.dart';

class PreferenciasScreen extends ConsumerWidget {
  const PreferenciasScreen({super.key});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _actualizar(
    BuildContext context,
    WidgetRef ref,
    String uid,
    UserPreferences nuevas,
  ) async {
    // Aplica el tema al instante (no espera la escritura en Firestore,
    // para que la UI se sienta inmediata).
    ref.read(themeModeProvider.notifier).set(
          nuevas.temaOscuro ? ThemeMode.dark : ThemeMode.light,
        );
    final ok = await ref
        .read(perfilControllerProvider.notifier)
        .updatePreferences(uid, nuevas);
    if (!ok && context.mounted) {
      final error = ref.read(perfilControllerProvider);
      error.whenOrNull(error: (e, _) => _showError(context, e.toString()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authStateProvider).value;
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final prefs = usuario.preferencias;

    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema oscuro'),
            subtitle: const Text('Aplica de inmediato en toda la app'),
            value: prefs.temaOscuro,
            onChanged: (value) => _actualizar(
              context,
              ref,
              usuario.uid,
              prefs.copyWith(temaOscuro: value),
            ),
          ),
          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Avisos de liturgia diaria y novedades'),
            value: prefs.notificacionesActivas,
            onChanged: (value) => _actualizar(
              context,
              ref,
              usuario.uid,
              prefs.copyWith(notificacionesActivas: value),
            ),
          ),
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(prefs.idioma == 'es' ? 'Español' : 'English'),
            trailing: DropdownButton<String>(
              value: prefs.idioma,
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _actualizar(
                  context,
                  ref,
                  usuario.uid,
                  prefs.copyWith(idioma: value),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'El cambio de idioma de los textos de la app se activará '
              'completamente en un módulo posterior; por ahora se guarda '
              'tu preferencia.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
