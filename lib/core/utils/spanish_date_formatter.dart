// lib/core/utils/spanish_date_formatter.dart

class SpanishDateFormatter {
  SpanishDateFormatter._();

  static const _diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  static const _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Ej: "Lunes 20 de julio"
  static String longDate(DateTime date) {
    final dia = _diasSemana[date.weekday - 1];
    final mes = _meses[date.month - 1];
    final texto = '$dia ${date.day} de $mes';
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
