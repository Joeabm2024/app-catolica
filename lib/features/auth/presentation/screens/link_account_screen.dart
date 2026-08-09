// lib/features/auth/presentation/screens/link_account_screen.dart
//
// Cierra el flujo que dejamos pendiente en el Módulo 1: un usuario invitado
// (esAnonimo == true) puede vincular su cuenta a Google o a correo/contraseña
// sin perder su UID ni los datos ya guardados en Firestore.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class LinkAccountScreen extends ConsumerStatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  ConsumerState<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends ConsumerState<LinkAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _mostrarFormularioEmail = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(loginControllerProvider.notifier);
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => _showError(error.toString()),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Guardar mi progreso')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.shield_outlined, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Vincula tu cuenta para que tu progreso, favoritos y '
                  'configuración no se pierdan si cambias de teléfono.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final ok = await controller.linkAnonymousToGoogle();
                          if (ok && context.mounted) context.pop();
                        },
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Vincular con Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_mostrarFormularioEmail)
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _mostrarFormularioEmail = true),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Vincular con correo y contraseña'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (_mostrarFormularioEmail) ...[
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Correo inválido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordCtrl,
                    label: 'Contraseña',
                    obscureText: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Mínimo 8 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Vincular cuenta',
                    isLoading: isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final ok = await controller.linkAnonymousToEmail(
                          _emailCtrl.text.trim(),
                          _passwordCtrl.text.trim(),
                        );
                        if (ok && context.mounted) context.pop();
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: const Text('Ahora no'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
