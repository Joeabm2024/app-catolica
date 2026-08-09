import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/rosario_model.dart';

class RosarioLocalDataSource {
  static const String rutaAsset = 'assets/data/rosario.json';

  final AssetBundle _assetBundle;

  ContenidoRosarioModel? _contenidoEnMemoria;

  RosarioLocalDataSource({
    AssetBundle? assetBundle,
  }) : _assetBundle = assetBundle ?? rootBundle;

  Future<ContenidoRosarioModel> cargarContenido() async {
    final contenidoGuardado = _contenidoEnMemoria;

    if (contenidoGuardado != null) {
      return contenidoGuardado;
    }

    try {
      final textoJson = await _assetBundle.loadString(
        rutaAsset,
      );

      final dynamic jsonDecodificado = jsonDecode(
        textoJson,
      );

      if (jsonDecodificado is! Map) {
        throw const FormatException(
          'La raíz de rosario.json debe ser un objeto.',
        );
      }

      final mapaJson = jsonDecodificado.map(
        (clave, valor) => MapEntry(
          clave.toString(),
          valor,
        ),
      );

      final contenido = ContenidoRosarioModel.fromJson(
        mapaJson,
      );

      _contenidoEnMemoria = contenido;

      return contenido;
    } on FlutterError catch (error) {
      throw RosarioAssetException(
        'No fue posible encontrar $rutaAsset. '
        'Verifica la sección assets de pubspec.yaml.',
        causa: error,
      );
    } on FormatException catch (error) {
      throw RosarioAssetException(
        'El contenido de rosario.json no es válido: '
        '${error.message}',
        causa: error,
      );
    }
  }

  void limpiarCache() {
    _contenidoEnMemoria = null;
  }
}

class RosarioAssetException implements Exception {
  final String mensaje;
  final Object? causa;

  const RosarioAssetException(
    this.mensaje, {
    this.causa,
  });

  @override
  String toString() {
    return mensaje;
  }
}
