// lib/shared/widgets/profile_menu_tile.dart

import 'package:flutter/material.dart';

class ProfileMenuTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final Color? color;

  const ProfileMenuTile({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(titulo, style: TextStyle(color: color)),
      subtitle: subtitulo != null ? Text(subtitulo!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
