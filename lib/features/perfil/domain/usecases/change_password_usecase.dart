// lib/features/perfil/domain/usecases/change_password_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;
  const ChangePasswordUseCase(this.repository);

  Future<Either<AuthFailure, Unit>> call(String newPassword) {
    return repository.changePassword(newPassword);
  }
}
