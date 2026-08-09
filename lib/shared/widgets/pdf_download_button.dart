// lib/shared/widgets/pdf_download_button.dart
//
// Reutilizable para cualquier módulo que necesite ofrecer un PDF (Cantos
// ahora; potencialmente documentos de otros módulos más adelante). Usa
// url_launcher para abrir el PDF en el navegador/visor del sistema — es
// la opción más simple y confiable para un MVP, sin pedir permisos de
// almacenamiento adicionales en Android.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class PdfDownloadButton extends StatelessWidget {
  final String pdfUrl;
  final String label;

  const PdfDownloadButton({
    super.key,
    required this.pdfUrl,
    this.label = 'Descargar PDF',
  });

  Future<void> _abrir(BuildContext context) async {
    final uri = Uri.parse(pdfUrl);
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _abrir(context),
      icon: const Icon(Icons.picture_as_pdf_outlined),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size.fromHeight(46),
      ),
    );
  }
}
