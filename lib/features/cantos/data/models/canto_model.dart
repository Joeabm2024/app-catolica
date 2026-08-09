// lib/features/cantos/data/models/canto_model.dart

import '../../domain/entities/canto.dart';

class CantoModel extends Canto {
  const CantoModel({
    required super.id,
    required super.titulo,
    super.autor,
    required super.letra,
    required super.tiemposLiturgicos,
    required super.momentosMisa,
    super.pdfUrl,
    super.tonalidadOriginal,
    super.audioUrl,
    super.fuenteUrl,
    super.licencia,
    required super.publicado,
    required super.creadoPor,
  });

  factory CantoModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return CantoModel(
      id: id,
      titulo: _stringValue(data['titulo']),
      autor: _nullableStringValue(data['autor']),
      letra: _stringValue(data['letra']),
      tiemposLiturgicos: _stringListValue(
        data['tiemposLiturgicos'],
      ),
      momentosMisa: _stringListValue(
        data['momentosMisa'],
      ),
      pdfUrl: _nullableStringValue(data['pdfUrl']),
      tonalidadOriginal: _nullableStringValue(
        data['tonalidadOriginal'],
      ),
      audioUrl: _nullableStringValue(
        data['audioUrl'],
      ),
      fuenteUrl: _nullableStringValue(
        data['fuenteUrl'],
      ),
      licencia: _nullableStringValue(
        data['licencia'],
      ),

      // Si el campo no existe o no es true, el canto se considera
      // no publicado por seguridad.
      publicado: data['publicado'] == true,

      creadoPor: _stringValue(data['creadoPor']),
    );
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  static String? _nullableStringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static List<String> _stringListValue(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}