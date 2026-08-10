import '../../domain/entities/santo.dart';

class SantoModel extends Santo {
  const SantoModel({
    required super.id,
    required super.nombre,
    super.nombreSecular,
    required super.dia,
    required super.mes,
    required super.tipoCelebracion,
    required super.resumen,
    required super.virtud,
    required super.oracion,
    required super.imagenAsset,
    required super.imagenGeneradaConIA,
  });

  factory SantoModel.fromJson(Map<String, dynamic> json) {
    return SantoModel(
      id: _leerTextoRequerido(json, 'id'),
      nombre: _leerTextoRequerido(json, 'nombre'),
      nombreSecular: _leerTextoOpcional(json['nombreSecular']),
      dia: _leerEntero(json, 'dia'),
      mes: _leerEntero(json, 'mes'),
      tipoCelebracion: _leerTextoRequerido(json, 'tipoCelebracion'),
      resumen: _leerTextoRequerido(json, 'resumen'),
      virtud: _leerTextoRequerido(json, 'virtud'),
      oracion: _leerTextoRequerido(json, 'oracion'),
      imagenAsset: _leerTextoRequerido(json, 'imagenAsset'),
      imagenGeneradaConIA: json['imagenGeneradaConIA'] == true,
    );
  }

  static String _leerTextoRequerido(Map<String, dynamic> json, String campo) {
    final valor = json[campo];

    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException('El campo "$campo" es obligatorio.');
    }

    return valor.trim();
  }

  static String? _leerTextoOpcional(dynamic valor) {
    if (valor is! String) {
      return null;
    }

    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }

  static int _leerEntero(Map<String, dynamic> json, String campo) {
    final valor = json[campo];

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    final convertido = int.tryParse(valor?.toString() ?? '');

    if (convertido == null) {
      throw FormatException('El campo "$campo" debe ser un número entero.');
    }

    return convertido;
  }
}
