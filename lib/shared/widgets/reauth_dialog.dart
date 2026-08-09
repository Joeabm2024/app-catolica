// lib/shared/widgets/reauth_dialog.dart
//
// Recibe callbacks en vez de leer providers directamente, para que este
// widget compartido no dependa de 'features/perfil' — cualquier pantalla
// que necesite reautenticación (hoy: Cambiar Contraseña, Eliminar Cuenta)
// le pasa su propia lógica.

import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

class ReauthDialog extends StatefulWidget {
  final bool proveedorEsGoogle;
  final Future<bool> Function(String password) onReauthWithPassword;
  final Future<bool> Function() onReauthWithGoogle;

  const ReauthDialog({
    super.key,
    required this.proveedorEsGoogle,
    required this.onReauthWithPassword,
    required this.onReauthWithGoogle,
  });

  /// Retorna `true` si la reautenticación fue exitosa.
  static Future<bool> show(
    BuildContext context, {
    required bool proveedorEsGoogle,
    required Future<bool> Function(String password) onReauthWithPassword,
    required Future<bool> Function() onReauthWithGoogle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReauthDialog(
        proveedorEsGoogle: proveedorEsGoogle,
        onReauthWithPassword: onReauthWithPassword,
        onReauthWithGoogle: onReauthWithGoogle,
      ),
    );
    return result ?? false;
  }

  @override
  State<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<ReauthDialog> {
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);
    final ok = widget.proveedorEsGoogle
        ? await widget.onReauthWithGoogle()
        : await widget.onReauthWithPassword(_passwordCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirma tu identidad'),
      content: widget.proveedorEsGoogle
          ? const Text(
              'Por seguridad, vuelve a iniciar sesión con Google antes de continuar.',
            )
          : CustomTextField(
              controller: _passwordCtrl,
              label: 'Contraseña actual',
              obscureText: true,
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        SizedBox(
          width: 140,
          child: PrimaryButton(
            text: widget.proveedorEsGoogle ? 'Continuar con Google' : 'Confirmar',
            isLoading: _isLoading,
            onPressed: _confirmar,
          ),
        ),
      ],
    );
  }
}
