class TiempoLiturgicoOpcion {
  final String id;
  final String etiqueta;

  const TiempoLiturgicoOpcion(
    this.id,
    this.etiqueta,
  );
}

class MomentoMisaOpcion {
  final String id;
  final String etiqueta;

  const MomentoMisaOpcion(
    this.id,
    this.etiqueta,
  );
}

class CantosConstants {
  CantosConstants._();

  static const List<TiempoLiturgicoOpcion> tiemposLiturgicos = [
    TiempoLiturgicoOpcion('todos', 'Todos'),
    TiempoLiturgicoOpcion('adviento', 'Adviento'),
    TiempoLiturgicoOpcion('navidad', 'Navidad'),
    TiempoLiturgicoOpcion('cuaresma', 'Cuaresma'),
    TiempoLiturgicoOpcion('pascua', 'Pascua'),
    TiempoLiturgicoOpcion(
      'tiempo_ordinario',
      'Tiempo Ordinario',
    ),
  ];

 static const List<MomentoMisaOpcion> momentosMisa = [
  MomentoMisaOpcion('entrada', 'Entrada'),
  MomentoMisaOpcion('acto_penitencial', 'Perdón'),
  MomentoMisaOpcion('gloria', 'Gloria'),
  MomentoMisaOpcion('salmo', 'Salmos'),
  MomentoMisaOpcion('aclamacion', 'Aleluya'),
  MomentoMisaOpcion('leccional', 'Leccionales'),
  MomentoMisaOpcion('ofertorio', 'Ofertorio'),
  MomentoMisaOpcion('santo', 'Santo'),
  MomentoMisaOpcion('padrenuestro', 'Padrenuestro'),
  MomentoMisaOpcion('paz', 'Paz'),
  MomentoMisaOpcion('cordero', 'Cordero'),
  MomentoMisaOpcion('comunion', 'Comunión'),
  MomentoMisaOpcion('espiritu_santo', 'Espíritu Santo'),
  MomentoMisaOpcion('salida', 'Salida'),
  MomentoMisaOpcion('mariano', 'Marianos'),
  MomentoMisaOpcion('rosario', 'Rosario'),
  MomentoMisaOpcion('matrimonio', 'Matrimonio'),
  MomentoMisaOpcion(
    'liturgia_especial',
    'Liturgias especiales',
  ),
  MomentoMisaOpcion('agustiniano', 'Agustinianos'),
  MomentoMisaOpcion('villancico', 'Villancicos'),
  MomentoMisaOpcion('varios', 'Varios'),
];

  static String etiquetaTiempo(String id) {
    return tiemposLiturgicos
        .firstWhere(
          (tiempo) => tiempo.id == id,
          orElse: () => TiempoLiturgicoOpcion(id, id),
        )
        .etiqueta;
  }

  static String etiquetaMomento(String id) {
    return momentosMisa
        .firstWhere(
          (momento) => momento.id == id,
          orElse: () => MomentoMisaOpcion(id, id),
        )
        .etiqueta;
  }
}