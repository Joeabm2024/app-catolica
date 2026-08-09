class OracionRosario {
  final String id;
  final String titulo;
  final String texto;

  const OracionRosario({
    required this.id,
    required this.titulo,
    required this.texto,
  });
}

class MisterioRosario {
  final int numero;
  final String nombre;
  final String citaBiblica;
  final String meditacion;

  const MisterioRosario({
    required this.numero,
    required this.nombre,
    required this.citaBiblica,
    required this.meditacion,
  });
}

class TipoMisteriosRosario {
  final String id;
  final String nombre;
  final String descripcion;
  final List<int> diasSemana;
  final List<MisterioRosario> misterios;

  const TipoMisteriosRosario({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.diasSemana,
    required this.misterios,
  });

  bool correspondeAlDia(DateTime fecha) {
    return diasSemana.contains(fecha.weekday);
  }
}

class ContenidoRosario {
  final int version;
  final String idioma;
  final Map<String, OracionRosario> oraciones;
  final List<TipoMisteriosRosario> tiposMisterios;

  const ContenidoRosario({
    required this.version,
    required this.idioma,
    required this.oraciones,
    required this.tiposMisterios,
  });

  OracionRosario? obtenerOracion(String id) {
    return oraciones[id];
  }

  TipoMisteriosRosario? obtenerTipoPorId(String id) {
    for (final tipo in tiposMisterios) {
      if (tipo.id == id) {
        return tipo;
      }
    }

    return null;
  }

  TipoMisteriosRosario obtenerTipoDelDia(DateTime fecha) {
    for (final tipo in tiposMisterios) {
      if (tipo.correspondeAlDia(fecha)) {
        return tipo;
      }
    }

    for (final tipo in tiposMisterios) {
      if (tipo.id == 'gloriosos') {
        return tipo;
      }
    }

    if (tiposMisterios.isEmpty) {
      throw StateError(
        'El contenido del Rosario no tiene tipos de misterios.',
      );
    }

    return tiposMisterios.first;
  }
}