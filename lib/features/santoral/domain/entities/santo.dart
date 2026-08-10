class Santo {
  final String id;
  final String nombre;
  final String? nombreSecular;
  final int dia;
  final int mes;
  final String tipoCelebracion;
  final String resumen;
  final String virtud;
  final String oracion;
  final String imagenAsset;
  final bool imagenGeneradaConIA;

  const Santo({
    required this.id,
    required this.nombre,
    this.nombreSecular,
    required this.dia,
    required this.mes,
    required this.tipoCelebracion,
    required this.resumen,
    required this.virtud,
    required this.oracion,
    required this.imagenAsset,
    required this.imagenGeneradaConIA,
  });

  bool correspondeAFecha(DateTime fecha) {
    return fecha.day == dia && fecha.month == mes;
  }

  String get fechaId {
    final mesTexto = mes.toString().padLeft(2, '0');
    final diaTexto = dia.toString().padLeft(2, '0');
    return '$mesTexto-$diaTexto';
  }
}
