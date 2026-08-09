// lib/features/oraciones/domain/usecases/toggle_favorito_oracion_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../repositories/oraciones_repository.dart';

class ToggleFavoritoOracionUseCase {
  final OracionesRepository repository;
  const ToggleFavoritoOracionUseCase(this.repository);

  Future<Either<CantosFailure, Unit>> call({
    required String uid,
    required String oracionId,
    required bool marcarComoFavorito,
  }) {
    return repository.toggleFavorito(
      uid: uid,
      oracionId: oracionId,
      marcarComoFavorito: marcarComoFavorito,
    );
  }
}
