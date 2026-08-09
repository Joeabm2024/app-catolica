// lib/features/cantos/domain/usecases/get_canto_by_id_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../entities/canto.dart';
import '../repositories/cantos_repository.dart';

class GetCantoByIdUseCase {
  final CantosRepository repository;
  const GetCantoByIdUseCase(this.repository);

  Future<Either<CantosFailure, Canto>> call(String id) {
    return repository.getCantoById(id);
  }
}
