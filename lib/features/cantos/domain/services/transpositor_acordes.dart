class TranspositorAcordes {
  TranspositorAcordes._();

  static const List<String> tonalidadesDisponibles = [
    'DO',
    'REb',
    'RE',
    'MIb',
    'MI',
    'FA',
    'SOLb',
    'SOL',
    'LAb',
    'LA',
    'SIb',
    'SI',
  ];

  static const Map<String, int> _semitonos = {
    'DO': 0,
    'DO#': 1,
    'REb': 1,
    'RE': 2,
    'RE#': 3,
    'MIb': 3,
    'MI': 4,
    'FAb': 4,
    'MI#': 5,
    'FA': 5,
    'FA#': 6,
    'SOLb': 6,
    'SOL': 7,
    'SOL#': 8,
    'LAb': 8,
    'LA': 9,
    'LA#': 10,
    'SIb': 10,
    'SI': 11,
    'DOb': 11,
  };

  static const List<String> _notasSostenidas = [
    'DO',
    'DO#',
    'RE',
    'RE#',
    'MI',
    'FA',
    'FA#',
    'SOL',
    'SOL#',
    'LA',
    'LA#',
    'SI',
  ];

  static const List<String> _notasBemoles = [
    'DO',
    'REb',
    'RE',
    'MIb',
    'MI',
    'FA',
    'SOLb',
    'SOL',
    'LAb',
    'LA',
    'SIb',
    'SI',
  ];

  static final RegExp _acordeCompleto = RegExp(
    r'^(DO|RE|MI|FA|SOL|LA|SI)'
    r'([#b]?)'
    r'((?:m|maj|min|dim|aug|sus|add|M)?'
    r'[0-9]*(?:[()+\-°/]?[A-Za-z0-9#b]*)*)$',
    caseSensitive: false,
  );

  static final RegExp _notaInicial = RegExp(
    r'^(DO|RE|MI|FA|SOL|LA|SI)([#b]?)(.*)$',
    caseSensitive: false,
  );

  static String transponer({
    required String contenido,
    required String tonalidadOriginal,
    required String tonalidadDestino,
  }) {
    final original = normalizarTonalidad(tonalidadOriginal);
    final destino = normalizarTonalidad(tonalidadDestino);

    final semitonoOriginal = _semitonos[original];
    final semitonoDestino = _semitonos[destino];

    if (semitonoOriginal == null || semitonoDestino == null) {
      return contenido;
    }

    final desplazamiento =
        (semitonoDestino - semitonoOriginal + 12) % 12;

    if (desplazamiento == 0) {
      return contenido;
    }

    final usarBemoles = _debeUsarBemoles(destino);

    final lineas = contenido.split('\n');

    return lineas.map((linea) {
      if (!_esLineaDeAcordes(linea)) {
        return linea;
      }

      return linea.replaceAllMapped(
        RegExp(r'\S+'),
        (coincidencia) {
          final acorde = coincidencia.group(0) ?? '';

          return _transponerAcorde(
            acorde: acorde,
            desplazamiento: desplazamiento,
            usarBemoles: usarBemoles,
          );
        },
      );
    }).join('\n');
  }

  static String? detectarTonalidad(String contenido) {
    final lineas = contenido.split('\n');

    for (final linea in lineas) {
      if (!_esLineaDeAcordes(linea)) {
        continue;
      }

      final acordes = RegExp(r'\S+')
          .allMatches(linea)
          .map((match) => match.group(0))
          .whereType<String>();

      for (final acorde in acordes) {
        final coincidencia = _notaInicial.firstMatch(acorde);

        if (coincidencia == null) {
          continue;
        }

        final nota = coincidencia.group(1) ?? '';
        final alteracion = coincidencia.group(2) ?? '';
        final tonalidad = normalizarTonalidad(
          '$nota$alteracion',
        );

        if (_semitonos.containsKey(tonalidad)) {
          return tonalidad;
        }
      }
    }

    return null;
  }

  static String normalizarTonalidad(String tonalidad) {
    final limpia = tonalidad
        .trim()
        .replaceAll('♯', '#')
        .replaceAll('♭', 'b');

    if (limpia.isEmpty) {
      return '';
    }

    final mayuscula = limpia.toUpperCase();

    if (mayuscula.endsWith('B')) {
      return '${mayuscula.substring(0, mayuscula.length - 1)}b';
    }

    return mayuscula;
  }

  static bool _esLineaDeAcordes(String linea) {
    final texto = linea.trim();

    if (texto.isEmpty) {
      return false;
    }

    final elementos = RegExp(r'\S+')
        .allMatches(texto)
        .map((match) => match.group(0))
        .whereType<String>()
        .toList();

    if (elementos.isEmpty) {
      return false;
    }

    return elementos.every(_pareceAcorde);
  }

  static bool _pareceAcorde(String texto) {
    final acorde = texto
        .replaceAll(',', '')
        .replaceAll(';', '')
        .trim();

    return _acordeCompleto.hasMatch(acorde);
  }

  static String _transponerAcorde({
    required String acorde,
    required int desplazamiento,
    required bool usarBemoles,
  }) {
    if (acorde.contains('/')) {
      final partes = acorde.split('/');

      if (partes.length == 2) {
        final acordePrincipal = _transponerAcordeSimple(
          acorde: partes[0],
          desplazamiento: desplazamiento,
          usarBemoles: usarBemoles,
        );

        final bajo = _transponerAcordeSimple(
          acorde: partes[1],
          desplazamiento: desplazamiento,
          usarBemoles: usarBemoles,
        );

        return '$acordePrincipal/$bajo';
      }
    }

    return _transponerAcordeSimple(
      acorde: acorde,
      desplazamiento: desplazamiento,
      usarBemoles: usarBemoles,
    );
  }

  static String _transponerAcordeSimple({
    required String acorde,
    required int desplazamiento,
    required bool usarBemoles,
  }) {
    final coincidencia = _notaInicial.firstMatch(acorde);

    if (coincidencia == null) {
      return acorde;
    }

    final nota = coincidencia.group(1) ?? '';
    final alteracion = coincidencia.group(2) ?? '';
    final complemento = coincidencia.group(3) ?? '';

    final notaNormalizada = normalizarTonalidad(
      '$nota$alteracion',
    );

    final semitono = _semitonos[notaNormalizada];

    if (semitono == null) {
      return acorde;
    }

    final nuevoSemitono =
        (semitono + desplazamiento) % 12;

    final notas =
        usarBemoles ? _notasBemoles : _notasSostenidas;

    return '${notas[nuevoSemitono]}$complemento';
  }

  static bool _debeUsarBemoles(String tonalidadDestino) {
    return const {
      'FA',
      'SIb',
      'MIb',
      'LAb',
      'REb',
      'SOLb',
    }.contains(tonalidadDestino);
  }
}