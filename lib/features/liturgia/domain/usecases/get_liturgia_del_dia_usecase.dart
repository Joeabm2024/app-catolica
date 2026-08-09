// lib/features/liturgia/domain/usecases/get_liturgia_del_dia_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/liturgia_failure.dart';
import '../entities/liturgia_del_dia.dart';
import '../repositories/liturgia_repository.dart';

class GetLiturgiaDelDiaUseCase {
  final LiturgiaRepository repository;
  const GetLiturgiaDelDiaUseCase(this.repository);

  Future<Either<LiturgiaFailure, LiturgiaDelDia>> call(DateTime fecha) {
    return repository.getLiturgiaDelDia(fecha);
  }
}
