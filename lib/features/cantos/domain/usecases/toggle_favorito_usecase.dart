// lib/features/cantos/domain/usecases/toggle_favorito_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../repositories/cantos_repository.dart';

class ToggleFavoritoUseCase {
  final CantosRepository repository;
  const ToggleFavoritoUseCase(this.repository);

  Future<Either<CantosFailure, Unit>> call({
    required String uid,
    required String cantoId,
    required bool marcarComoFavorito,
  }) {
    return repository.toggleFavorito(
      uid: uid,
      cantoId: cantoId,
      marcarComoFavorito: marcarComoFavorito,
    );
  }
}
