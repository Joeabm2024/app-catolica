// lib/features/auth/domain/usecases/send_password_reset_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final AuthRepository repository;
  const SendPasswordResetUseCase(this.repository);

  Future<Either<AuthFailure, Unit>> call({required String email}) {
    return repository.sendPasswordReset(email: email);
  }
}
