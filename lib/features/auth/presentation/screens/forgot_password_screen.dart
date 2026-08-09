// lib/features/auth/presentation/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
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
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 24),
                if (_sent) ...[
                  const Icon(Icons.mark_email_read_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Te enviamos un enlace a ${_emailCtrl.text.trim()} '
                    'para restablecer tu contraseña.',
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const Text(
                    'Ingresa tu correo y te enviaremos un enlace para '
                    'restablecer tu contraseña.',
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Correo inválido'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Enviar enlace',
                    isLoading: isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final ok = await controller
                            .sendPasswordReset(_emailCtrl.text.trim());
                        if (ok && mounted) setState(() => _sent = true);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
