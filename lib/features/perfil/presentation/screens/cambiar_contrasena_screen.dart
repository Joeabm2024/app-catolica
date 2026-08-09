// lib/features/perfil/presentation/screens/cambiar_contrasena_screen.dart
//
// Solo accesible si proveedor == 'password' (ver PerfilScreen). Pide la
// contraseña actual (reautenticación, exigida por Firebase) y luego la
// nueva contraseña, en un solo formulario.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/perfil_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class CambiarContrasenaScreen extends ConsumerStatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  ConsumerState<CambiarContrasenaScreen> createState() =>
      _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState
    extends ConsumerState<CambiarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(perfilControllerProvider.notifier);

    final reautenticado =
        await controller.reauthenticateWithPassword(_actualCtrl.text.trim());
    if (!reautenticado) return; // el error ya se muestra vía ref.listen

    final ok = await controller.changePassword(_nuevaCtrl.text.trim());
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(perfilControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(perfilControllerProvider, (previous, next) {
      next.whenOrNull(error: (error, _) => _showError(error.toString()));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _actualCtrl,
                  label: 'Contraseña actual',
                  obscureText: _obscure,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerida' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nuevaCtrl,
                  label: 'Nueva contraseña',
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmarCtrl,
                  label: 'Confirmar nueva contraseña',
                  obscureText: _obscure,
                  validator: (v) => (v != _nuevaCtrl.text)
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Actualizar contraseña',
                  isLoading: isLoading,
                  onPressed: _guardar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
