// lib/features/liturgia/domain/repositories/liturgia_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/liturgia_failure.dart';
import '../entities/liturgia_del_dia.dart';

abstract class LiturgiaRepository {
  Future<Either<LiturgiaFailure, LiturgiaDelDia>>
      getLiturgiaDelDia(
    DateTime fecha,
  );
}