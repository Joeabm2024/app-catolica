// lib/features/oraciones/domain/entities/oracion.dart

class Oracion {
  final String id;
  final String titulo;
  final String categoria;
  final String texto;
  final int orden;
  final String creadoPor;

  const Oracion({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.texto,
    required this.orden,
    required this.creadoPor,
  });

  Oracion copyWith({
    String? titulo,
    String? categoria,
    String? texto,
    int? orden,
  }) {
    return Oracion(
      id: id,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      texto: texto ?? this.texto,
      orden: orden ?? this.orden,
      creadoPor: creadoPor,
    );
  }
}
