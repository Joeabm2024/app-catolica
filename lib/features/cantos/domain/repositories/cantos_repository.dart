// lib/features/cantos/domain/repositories/
// cantos_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/cantos_failure.dart';
import '../entities/canto.dart';

abstract class CantosRepository {
  /// Escucha únicamente las canciones publicadas.
  ///
  /// Los filtros por texto, tiempo litúrgico y momento de la
  /// misa se aplican posteriormente en la capa de presentación.
  Stream<List<Canto>> watchCantos();

  /// Obtiene una canción publicada mediante su identificador.
  Future<Either<CantosFailure, Canto>> getCantoById(
    String id,
  );

  /// Agrega o elimina una canción de los favoritos del usuario.
  ///
  /// Esta operación no modifica la canción original.
  Future<Either<CantosFailure, Unit>> toggleFavorito({
    required String uid,
    required String cantoId,
    required bool marcarComoFavorito,
  });

  /// Escucha los identificadores de los cantos favoritos.
  Stream<Set<String>> watchFavoritos(
    String uid,
  );
}