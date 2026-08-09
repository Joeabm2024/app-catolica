// lib/features/oraciones/data/models/oracion_model.dart

import '../../domain/entities/oracion.dart';

class OracionModel extends Oracion {
  const OracionModel({
    required super.id,
    required super.titulo,
    required super.categoria,
    required super.texto,
    required super.orden,
    required super.creadoPor,
  });

  factory OracionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OracionModel(
      id: id,
      titulo: data['titulo'] ?? '',
      categoria: data['categoria'] ?? '',
      texto: data['texto'] ?? '',
      orden: data['orden'] ?? 0,
      creadoPor: data['creadoPor'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'categoria': categoria,
      'texto': texto,
      'orden': orden,
      'creadoPor': creadoPor,
    };
  }

  factory OracionModel.fromEntity(Oracion entity) {
    return OracionModel(
      id: entity.id,
      titulo: entity.titulo,
      categoria: entity.categoria,
      texto: entity.texto,
      orden: entity.orden,
      creadoPor: entity.creadoPor,
    );
  }
}
