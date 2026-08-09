// lib/core/constants/liturgical_colors.dart
//
// Mapea el string 'colorLiturgico' guardado en Firestore (español, sin
// tildes/minúsculas por convención de datos) al Color real y a un ícono
// representativo, para usar en ColorLiturgicoChip.

import 'package:flutter/material.dart';

class LiturgicalColorInfo {
  final Color color;
  final Color colorTexto;
  final String etiqueta;

  const LiturgicalColorInfo({
    required this.color,
    required this.colorTexto,
    required this.etiqueta,
  });
}

class LiturgicalColors {
  LiturgicalColors._();

  static const _mapa = <String, LiturgicalColorInfo>{
    'verde': LiturgicalColorInfo(
      color: Color(0xFF2E7D32),
      colorTexto: Colors.white,
      etiqueta: 'Verde',
    ),
    'morado': LiturgicalColorInfo(
      color: Color(0xFF6B2C91),
      colorTexto: Colors.white,
      etiqueta: 'Morado',
    ),
    'blanco': LiturgicalColorInfo(
      color: Color(0xFFF5F5F5),
      colorTexto: Color(0xFF1C1C1E),
      etiqueta: 'Blanco',
    ),
    'rojo': LiturgicalColorInfo(
      color: Color(0xFFB00020),
      colorTexto: Colors.white,
      etiqueta: 'Rojo',
    ),
    'rosa': LiturgicalColorInfo(
      color: Color(0xFFE91E8C),
      colorTexto: Colors.white,
      etiqueta: 'Rosa',
    ),
  };

  static const _fallback = LiturgicalColorInfo(
    color: Color(0xFF9E9E9E),
    colorTexto: Colors.white,
    etiqueta: 'Sin definir',
  );

  static LiturgicalColorInfo from(String? colorLiturgico) {
    if (colorLiturgico == null) return _fallback;
    return _mapa[colorLiturgico.toLowerCase()] ?? _fallback;
  }

  /// Valores válidos, usados también para poblar el dropdown del admin.
  static List<String> get valoresValidos => _mapa.keys.toList();
}
