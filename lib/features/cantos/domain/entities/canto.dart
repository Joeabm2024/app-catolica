// lib/features/cantos/domain/entities/canto.dart

class Canto {
  final String id;
  final String titulo;
  final String? autor;

  /// Contiene la letra y los acordes conservando sus espacios.
  final String letra;

  final List<String> tiemposLiturgicos;
  final List<String> momentosMisa;

  /// PDF opcional asociado con el canto.
  final String? pdfUrl;

  /// Tonalidad original, por ejemplo: DO, RE, MIm.
  final String? tonalidadOriginal;

  /// Dirección del audio original, cuando esté disponible.
  final String? audioUrl;

  /// Página desde la que se obtuvo la información.
  final String? fuenteUrl;

  /// Información sobre autorización o licencia.
  final String? licencia;

  /// Determina si la canción puede mostrarse a los usuarios.
  final bool publicado;

  /// Identificador del proceso o administrador que creó el registro.
  final String creadoPor;

  const Canto({
    required this.id,
    required this.titulo,
    this.autor,
    required this.letra,
    required this.tiemposLiturgicos,
    required this.momentosMisa,
    this.pdfUrl,
    this.tonalidadOriginal,
    this.audioUrl,
    this.fuenteUrl,
    this.licencia,
    required this.publicado,
    required this.creadoPor,
  });
}