import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/liturgia_del_dia.dart';

class LiturgiaModel extends LiturgiaDelDia {
  const LiturgiaModel({
    required super.id,
    required super.fecha,
    required super.primeraLectura,
    super.salmoResponsorial,
    super.segundaLectura,
    required super.evangelio,
    required super.versionBiblia,
    required super.fuente,
    required super.publicado,
  });

  factory LiturgiaModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return LiturgiaModel(
      id: documentId,
      fecha: _fecha(data['fecha'], documentId),
      primeraLectura: _lectura(
        _map(data['primeraLectura']),
        tipo: 'firstReading',
        titulo: 'Primera lectura',
      ),
      salmoResponsorial: _lecturaOpcional(
        data['salmo'],
        tipo: 'psalm',
        titulo: 'Salmo responsorial',
      ),
      segundaLectura: _lecturaOpcional(
        data['segundaLectura'],
        tipo: 'secondReading',
        titulo: 'Segunda lectura',
      ),
      evangelio: _lectura(
        _map(data['evangelio']),
        tipo: 'gospel',
        titulo: 'Evangelio',
      ),
      versionBiblia: _version(_map(data['versionBiblia'])),
      fuente: _fuente(_map(data['fuente'])),
      publicado: data['publicado'] == true,
    );
  }

  static LecturaBiblica _lectura(
    Map<String, dynamic> map, {
    required String tipo,
    required String titulo,
  }) {
    return LecturaBiblica(
      tipo: _texto(map['tipo'], tipo),
      titulo: _texto(map['titulo'], titulo),
      referencia: _texto(map['referencia']),
      libro: _texto(map['libro']),
      texto: _texto(map['texto']),
    );
  }

  static LecturaBiblica? _lecturaOpcional(
    dynamic value, {
    required String tipo,
    required String titulo,
  }) {
    if (value == null) return null;
    final map = _map(value);
    if (map.isEmpty) return null;
    final lectura = _lectura(map, tipo: tipo, titulo: titulo);
    return lectura.tieneContenido ? lectura : null;
  }

  static VersionBiblia _version(Map<String, dynamic> map) {
    return VersionBiblia(
      codigo: _texto(map['codigo']),
      nombre: _texto(map['nombre']),
      abreviatura: _texto(map['abreviatura']),
    );
  }

  static FuenteLiturgia _fuente(Map<String, dynamic> map) {
    return FuenteLiturgia(
      nombre: _texto(map['nombre'], 'Cathople'),
      apiUrl: _textoOpcional(map['api']),
      enlace: _textoOpcional(map['enlace']),
    );
  }

  static DateTime _fecha(dynamic value, String documentId) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.tryParse(documentId) ?? DateTime.now();
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _texto(dynamic value, [String fallback = '']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String? _textoOpcional(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? null : result;
  }
}
