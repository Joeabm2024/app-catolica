// lib/features/oraciones/domain/repositories/oraciones_repository.dart
//
// Mismo patrón de diseño que CantosRepository (Módulo 5): lecturas del
// catálogo como Stream plano (AsyncValue maneja errores solo), escrituras
// con Either para que la UI distinga éxito/fracaso de un intento puntual.
// Reutiliza CantosFailure: los tipos de error (permiso, red, desconocido)
// son genéricos y no ameritan duplicar la misma jerarquía de excepciones.

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../entities/oracion.dart';

abstract class OracionesRepository {
  Stream<List<Oracion>> watchOraciones();

  Future<Either<CantosFailure, Unit>> guardarOracion(Oracion oracion);

  Future<Either<CantosFailure, Unit>> eliminarOracion(String id);

  Future<Either<CantosFailure, Unit>> toggleFavorito({
    required String uid,
    required String oracionId,
    required bool marcarComoFavorito,
  });

  Stream<Set<String>> watchFavoritos(String uid);
}
