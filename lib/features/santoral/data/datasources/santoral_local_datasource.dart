import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/santo_model.dart';

class SantoralLocalException implements Exception {
  final String message;

  const SantoralLocalException(this.message);

  @override
  String toString() => message;
}

class SantoralLocalDataSource {
  static const String _rutaAsset = 'assets/data/santos.json';

  List<SantoModel>? _cache;

  Future<List<SantoModel>> obtenerSantos() async {
    final santosGuardados = _cache;

    if (santosGuardados != null) {
      return santosGuardados;
    }

    try {
      final contenido = await rootBundle.loadString(_rutaAsset);

      final dynamic jsonDecodificado = jsonDecode(contenido);

      if (jsonDecodificado is! Map<String, dynamic>) {
        throw const SantoralLocalException(
          'El archivo del Santoral no tiene un formato válido.',
        );
      }

      final dynamic listaJson = jsonDecodificado['santos'];

      if (listaJson is! List) {
        throw const SantoralLocalException('No se encontró la lista "santos".');
      }

      final santos = listaJson.map((elemento) {
        if (elemento is! Map) {
          throw const SantoralLocalException(
            'Existe un santo con formato inválido.',
          );
        }

        return SantoModel.fromJson(Map<String, dynamic>.from(elemento));
      }).toList();

      _validarSantos(santos);

      santos.sort((primero, segundo) {
        final comparacionMes = primero.mes.compareTo(segundo.mes);

        if (comparacionMes != 0) {
          return comparacionMes;
        }

        return primero.dia.compareTo(segundo.dia);
      });

      _cache = List<SantoModel>.unmodifiable(santos);
      return _cache!;
    } on SantoralLocalException {
      rethrow;
    } on FormatException catch (error) {
      throw SantoralLocalException(
        'El JSON del Santoral contiene un error: '
        '${error.message}',
      );
    } catch (error) {
      throw SantoralLocalException('No fue posible cargar el Santoral: $error');
    }
  }

  Future<SantoModel?> obtenerSantoDelDia(DateTime fecha) async {
    final santos = await obtenerSantos();

    for (final santo in santos) {
      if (santo.correspondeAFecha(fecha)) {
        return santo;
      }
    }

    return null;
  }

  void limpiarCache() {
    _cache = null;
  }

  void _validarSantos(List<SantoModel> santos) {
    final ids = <String>{};

    for (final santo in santos) {
      if (!ids.add(santo.id)) {
        throw SantoralLocalException('El ID "${santo.id}" está duplicado.');
      }

      if (santo.mes < 1 || santo.mes > 12) {
        throw SantoralLocalException(
          'El mes de "${santo.nombre}" no es válido.',
        );
      }

      final ultimoDiaDelMes = DateTime(2024, santo.mes + 1, 0).day;

      if (santo.dia < 1 || santo.dia > ultimoDiaDelMes) {
        throw SantoralLocalException(
          'El día de "${santo.nombre}" no es válido.',
        );
      }
    }
  }
}
