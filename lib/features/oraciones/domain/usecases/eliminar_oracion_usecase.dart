// lib/features/oraciones/domain/usecases/eliminar_oracion_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../repositories/oraciones_repository.dart';

class EliminarOracionUseCase {
  final OracionesRepository repository;
  const EliminarOracionUseCase(this.repository);

  Future<Either<CantosFailure, Unit>> call(String id) {
    return repository.eliminarOracion(id);
  }
}
