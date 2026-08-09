import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rosario.dart';

enum TipoPasoRosario {
  oracion,
  anuncioMisterio,
  aveMaria,
  finalizado,
}

class PasoGuiaRosario {
  final String id;
  final String titulo;
  final String texto;
  final TipoPasoRosario tipo;
  final int? numeroMisterio;
  final int? repeticionActual;
  final int? totalRepeticiones;

  const PasoGuiaRosario({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.tipo,
    this.numeroMisterio,
    this.repeticionActual,
    this.totalRepeticiones,
  });

  bool get esAveMaria {
    return tipo == TipoPasoRosario.aveMaria;
  }
}

class EstadoGuiaRosario {
  final String? tipoMisteriosId;
  final String? tipoMisteriosNombre;
  final List<PasoGuiaRosario> pasos;
  final int indiceActual;
  final bool iniciado;

  const EstadoGuiaRosario({
    this.tipoMisteriosId,
    this.tipoMisteriosNombre,
    this.pasos = const [],
    this.indiceActual = 0,
    this.iniciado = false,
  });

  PasoGuiaRosario? get pasoActual {
    if (pasos.isEmpty) {
      return null;
    }

    if (indiceActual < 0 || indiceActual >= pasos.length) {
      return null;
    }

    return pasos[indiceActual];
  }

  bool get estaFinalizado {
    return iniciado &&
        pasos.isNotEmpty &&
        indiceActual == pasos.length - 1;
  }

  bool get puedeRetroceder {
    return iniciado && indiceActual > 0;
  }

  bool get puedeAvanzar {
    return iniciado &&
        pasos.isNotEmpty &&
        indiceActual < pasos.length - 1;
  }

  double get progreso {
    if (pasos.isEmpty) {
      return 0;
    }

    return (indiceActual + 1) / pasos.length;
  }

  EstadoGuiaRosario copyWith({
    String? tipoMisteriosId,
    String? tipoMisteriosNombre,
    List<PasoGuiaRosario>? pasos,
    int? indiceActual,
    bool? iniciado,
  }) {
    return EstadoGuiaRosario(
      tipoMisteriosId:
          tipoMisteriosId ?? this.tipoMisteriosId,
      tipoMisteriosNombre:
          tipoMisteriosNombre ?? this.tipoMisteriosNombre,
      pasos: pasos ?? this.pasos,
      indiceActual: indiceActual ?? this.indiceActual,
      iniciado: iniciado ?? this.iniciado,
    );
  }
}

class RosarioGuiaController
    extends Notifier<EstadoGuiaRosario> {
  @override
  EstadoGuiaRosario build() {
    return const EstadoGuiaRosario();
  }

  void iniciar({
    required ContenidoRosario contenido,
    required TipoMisteriosRosario tipoMisterios,
  }) {
    final pasos = _construirPasos(
      contenido: contenido,
      tipoMisterios: tipoMisterios,
    );

    state = EstadoGuiaRosario(
      tipoMisteriosId: tipoMisterios.id,
      tipoMisteriosNombre: tipoMisterios.nombre,
      pasos: List.unmodifiable(pasos),
      indiceActual: 0,
      iniciado: true,
    );
  }

  void avanzar() {
    if (!state.puedeAvanzar) {
      return;
    }

    state = state.copyWith(
      indiceActual: state.indiceActual + 1,
    );
  }

  void retroceder() {
    if (!state.puedeRetroceder) {
      return;
    }

    state = state.copyWith(
      indiceActual: state.indiceActual - 1,
    );
  }

  void reiniciar() {
    if (state.pasos.isEmpty) {
      state = const EstadoGuiaRosario();
      return;
    }

    state = state.copyWith(
      indiceActual: 0,
      iniciado: true,
    );
  }

  void finalizar() {
    state = const EstadoGuiaRosario();
  }

  List<PasoGuiaRosario> _construirPasos({
    required ContenidoRosario contenido,
    required TipoMisteriosRosario tipoMisterios,
  }) {
    final pasos = <PasoGuiaRosario>[];

    void agregarOracion(
      String id, {
      String? titulo,
    }) {
      final oracion = contenido.obtenerOracion(id);

      if (oracion == null) {
        throw StateError(
          'No se encontró la oración $id.',
        );
      }

      pasos.add(
        PasoGuiaRosario(
          id: '${id}_${pasos.length}',
          titulo: titulo ?? oracion.titulo,
          texto: oracion.texto,
          tipo: TipoPasoRosario.oracion,
        ),
      );
    }

    agregarOracion('senalCruz');
    agregarOracion('credo');
    agregarOracion('padreNuestro');

    final aveMariaInicial = contenido.obtenerOracion(
      'aveMaria',
    );

    if (aveMariaInicial == null) {
      throw StateError(
        'No se encontró la oración aveMaria.',
      );
    }

    for (var numero = 1; numero <= 3; numero++) {
      pasos.add(
        PasoGuiaRosario(
          id: 'ave_maria_inicial_$numero',
          titulo: 'Ave María $numero de 3',
          texto: aveMariaInicial.texto,
          tipo: TipoPasoRosario.aveMaria,
          repeticionActual: numero,
          totalRepeticiones: 3,
        ),
      );
    }

    agregarOracion('gloria');

    for (final misterio in tipoMisterios.misterios) {
      pasos.add(
        PasoGuiaRosario(
          id: 'misterio_${misterio.numero}',
          titulo:
              '${misterio.numero}. ${misterio.nombre}',
          texto:
              '${misterio.citaBiblica}\n\n'
              '${misterio.meditacion}',
          tipo: TipoPasoRosario.anuncioMisterio,
          numeroMisterio: misterio.numero,
        ),
      );

      agregarOracion(
        'padreNuestro',
        titulo:
            'Padre Nuestro · '
            'Misterio ${misterio.numero}',
      );

      final aveMaria = contenido.obtenerOracion(
        'aveMaria',
      );

      if (aveMaria == null) {
        throw StateError(
          'No se encontró la oración aveMaria.',
        );
      }

      for (var numero = 1; numero <= 10; numero++) {
        pasos.add(
          PasoGuiaRosario(
            id:
                'misterio_${misterio.numero}_'
                'ave_maria_$numero',
            titulo: 'Ave María $numero de 10',
            texto: aveMaria.texto,
            tipo: TipoPasoRosario.aveMaria,
            numeroMisterio: misterio.numero,
            repeticionActual: numero,
            totalRepeticiones: 10,
          ),
        );
      }

      agregarOracion(
        'gloria',
        titulo:
            'Gloria · Misterio ${misterio.numero}',
      );

      agregarOracion(
        'jaculatoriaFatima',
        titulo:
            'Jaculatoria · '
            'Misterio ${misterio.numero}',
      );
    }

    agregarOracion('salve');
    agregarOracion('oracionFinal');
    agregarOracion(
      'senalCruz',
      titulo: 'Señal de la Cruz final',
    );

    pasos.add(
      const PasoGuiaRosario(
        id: 'rosario_finalizado',
        titulo: 'Rosario finalizado',
        texto:
            'Has completado los cinco misterios. '
            'Que esta oración dé fruto en tu vida.',
        tipo: TipoPasoRosario.finalizado,
      ),
    );

    return pasos;
  }
}

final rosarioGuiaControllerProvider = NotifierProvider<
    RosarioGuiaController,
    EstadoGuiaRosario>(
  RosarioGuiaController.new,
);

