// lib/features/liturgia/domain/entities/liturgia_del_dia.dart

class LecturaBiblica {
  final String tipo;
  final String titulo;
  final String referencia;
  final String libro;
  final String texto;

  const LecturaBiblica({
    required this.tipo,
    required this.titulo,
    required this.referencia,
    required this.libro,
    required this.texto,
  });

  bool get tieneContenido {
    return texto.trim().isNotEmpty;
  }
}

class VersionBiblia {
  final String codigo;
  final String nombre;
  final String abreviatura;

  const VersionBiblia({
    required this.codigo,
    required this.nombre,
    required this.abreviatura,
  });
}

class FuenteLiturgia {
  final String nombre;
  final String? apiUrl;
  final String? enlace;

  const FuenteLiturgia({
    required this.nombre,
    this.apiUrl,
    this.enlace,
  });
}

class LiturgiaDelDia {
  final String id;
  final DateTime fecha;
  final LecturaBiblica primeraLectura;
  final LecturaBiblica? salmoResponsorial;
  final LecturaBiblica? segundaLectura;
  final LecturaBiblica evangelio;
  final VersionBiblia versionBiblia;
  final FuenteLiturgia fuente;
  final bool publicado;

  const LiturgiaDelDia({
    required this.id,
    required this.fecha,
    required this.primeraLectura,
    this.salmoResponsorial,
    this.segundaLectura,
    required this.evangelio,
    required this.versionBiblia,
    required this.fuente,
    required this.publicado,
  });

  bool get tieneSegundaLectura {
    return segundaLectura != null &&
        segundaLectura!.tieneContenido;
  }

  bool get tieneSalmo {
    return salmoResponsorial != null &&
        salmoResponsorial!.tieneContenido;
  }
}