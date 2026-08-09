// lib/features/perfil/presentation/screens/eliminar_cuenta_screen.dart
//
// Flujo: ConfirmDialog (doble confirmación) -> ReauthDialog (adaptado a
// Google o contraseña según el proveedor) -> borrado real. Al eliminarse
// el usuario de Firebase Auth, authStateChanges emite null automáticamente
// y el redirect del router ya definido en Módulo 1 envía a /login solo —
// no hace falta llamar signOut() manualmente.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/perfil_providers.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/reauth_dialog.dart';
import '../../../../core/constants/app_colors.dart';

class EliminarCuentaScreen extends ConsumerStatefulWidget {
  const EliminarCuentaScreen({super.key});

  @override
  ConsumerState<EliminarCuentaScreen> createState() =>
      _EliminarCuentaScreenState();
}

class _EliminarCuentaScreenState extends ConsumerState<EliminarCuentaScreen> {
  bool _procesando = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _iniciarEliminacion() async {
    final usuario = ref.read(authStateProvider).value;
    if (usuario == null) return;

    final confirmado = await ConfirmDialog.show(
      context,
      titulo: 'Eliminar cuenta',
      mensaje:
          'Esta acción es permanente. Se borrarán tu perfil, tu foto y tu '
          'progreso. No se puede deshacer. ¿Deseas continuar?',
      textoConfirmar: 'Eliminar',
      esDestructivo: true,
    );
    if (!confirmado || !mounted) return;

    final controller = ref.read(perfilControllerProvider.notifier);

    // Los invitados (esAnonimo) no tienen credencial que reautenticar.
    final reautenticado = usuario.esAnonimo
        ? true
        : await ReauthDialog.show(
            context,
            proveedorEsGoogle: usuario.proveedor == 'google',
            onReauthWithPassword: controller.reauthenticateWithPassword,
            onReauthWithGoogle: controller.reauthenticateWithGoogle,
          );
    if (!reautenticado || !mounted) return;

    setState(() => _procesando = true);
    final ok = await controller.deleteAccount(usuario.uid);
    if (!mounted) return;
    setState(() => _procesando = false);

    if (!ok) {
      final error = ref.read(perfilControllerProvider);
      error.whenOrNull(error: (e, _) => _showError(e.toString()));
    }
    // Si tuvo éxito, el redirect del router se encarga de navegar a /login.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar cuenta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Al eliminar tu cuenta perderás de forma permanente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const _ItemPerdida(texto: 'Tu perfil y foto'),
              const _ItemPerdida(texto: 'Tus preferencias guardadas'),
              const _ItemPerdida(
                  texto: 'Tu progreso en oraciones y favoritos'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _procesando ? null : _iniciarEliminacion,
                  icon: _procesando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_forever),
                  label: const Text('Eliminar mi cuenta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemPerdida extends StatelessWidget {
  final String texto;
  const _ItemPerdida({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.close, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Text(texto),
        ],
      ),
    );
  }
}
