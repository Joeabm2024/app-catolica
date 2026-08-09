// lib/features/oraciones/domain/usecases/guardar_oracion_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../entities/oracion.dart';
import '../repositories/oraciones_repository.dart';

class GuardarOracionUseCase {
  final OracionesRepository repository;
  const GuardarOracionUseCase(this.repository);

  Future<Either<CantosFailure, Unit>> call(Oracion oracion) {
    return repository.guardarOracion(oracion);
  }
}
