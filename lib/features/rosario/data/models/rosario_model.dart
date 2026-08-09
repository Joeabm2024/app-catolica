import '../../domain/entities/rosario.dart';

class OracionRosarioModel extends OracionRosario {
  const OracionRosarioModel({
    required super.id,
    required super.titulo,
    required super.texto,
  });

  factory OracionRosarioModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return OracionRosarioModel(
      id: id,
      titulo: _texto(json['titulo']),
      texto: _texto(json['texto']),
    );
  }
}

class MisterioRosarioModel extends MisterioRosario {
  const MisterioRosarioModel({
    required super.numero,
    required super.nombre,
    required super.citaBiblica,
    required super.meditacion,
  });

  factory MisterioRosarioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MisterioRosarioModel(
      numero: _entero(json['numero']),
      nombre: _texto(json['nombre']),
      citaBiblica: _texto(json['citaBiblica']),
      meditacion: _texto(json['meditacion']),
    );
  }
}

class TipoMisteriosRosarioModel extends TipoMisteriosRosario {
  const TipoMisteriosRosarioModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.diasSemana,
    required super.misterios,
  });

  factory TipoMisteriosRosarioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final diasJson = json['diasSemana'];
    final misteriosJson = json['misterios'];

    final dias = diasJson is List
        ? diasJson.map(_entero).toList(growable: false)
        : const <int>[];

    final misterios = misteriosJson is List
        ? misteriosJson
            .whereType<Map>()
            .map(
              (item) => MisterioRosarioModel.fromJson(
                _mapa(item),
              ),
            )
            .toList(growable: false)
        : const <MisterioRosarioModel>[];

    return TipoMisteriosRosarioModel(
      id: _texto(json['id']),
      nombre: _texto(json['nombre']),
      descripcion: _texto(json['descripcion']),
      diasSemana: dias,
      misterios: misterios,
    );
  }
}

class ContenidoRosarioModel extends ContenidoRosario {
  const ContenidoRosarioModel({
    required super.version,
    required super.idioma,
    required super.oraciones,
    required super.tiposMisterios,
  });

  factory ContenidoRosarioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final oracionesJson = _mapa(json['oraciones']);
    final tiposJson = json['tiposMisterios'];

    final oraciones = <String, OracionRosarioModel>{};

    for (final entrada in oracionesJson.entries) {
      final valor = entrada.value;

      if (valor is Map) {
        oraciones[entrada.key] = OracionRosarioModel.fromJson(
          entrada.key,
          _mapa(valor),
        );
      }
    }

    final tipos = tiposJson is List
        ? tiposJson
            .whereType<Map>()
            .map(
              (item) => TipoMisteriosRosarioModel.fromJson(
                _mapa(item),
              ),
            )
            .toList(growable: false)
        : const <TipoMisteriosRosarioModel>[];

    if (oraciones.isEmpty) {
      throw const FormatException(
        'El JSON del Rosario no contiene oraciones.',
      );
    }

    if (tipos.length != 4) {
      throw FormatException(
        'Se esperaban 4 tipos de misterios, '
        'pero se encontraron ${tipos.length}.',
      );
    }

    for (final tipo in tipos) {
      if (tipo.misterios.length != 5) {
        throw FormatException(
          '${tipo.nombre} debe contener 5 misterios.',
        );
      }
    }

    return ContenidoRosarioModel(
      version: _entero(json['version']),
      idioma: _texto(json['idioma'], 'es'),
      oraciones: Map.unmodifiable(oraciones),
      tiposMisterios: List.unmodifiable(tipos),
    );
  }
}

Map<String, dynamic> _mapa(dynamic valor) {
  if (valor is Map<String, dynamic>) {
    return valor;
  }

  if (valor is Map) {
    return valor.map(
      (clave, contenido) => MapEntry(
        clave.toString(),
        contenido,
      ),
    );
  }

  return <String, dynamic>{};
}

String _texto(
  dynamic valor, [
  String valorPredeterminado = '',
]) {
  final texto = valor?.toString().trim() ?? '';

  if (texto.isEmpty) {
    return valorPredeterminado;
  }

  return texto;
}

int _entero(dynamic valor) {
  if (valor is int) {
    return valor;
  }

  return int.tryParse(valor?.toString() ?? '') ?? 0;
}