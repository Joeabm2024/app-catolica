// lib/shared/widgets/confirm_dialog.dart
//
// Diálogo genérico de confirmación, reutilizable por cualquier acción
// destructiva de la app (aquí: eliminar cuenta; más adelante: eliminar
// intenciones de oración, comentarios, etc. en otros módulos).

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final bool esDestructivo;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.esDestructivo = false,
  });

  /// Retorna `true` si el usuario confirmó, `false`/`null` si canceló.
  static Future<bool> show(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    bool esDestructivo = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        esDestructivo: esDestructivo,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: esDestructivo ? AppColors.error : AppColors.primary,
          ),
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
