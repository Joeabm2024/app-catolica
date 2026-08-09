// lib/features/auth/domain/usecases/sign_out_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  const SignOutUseCase(this.repository);

  Future<Either<AuthFailure, Unit>> call() {
    return repository.signOut();
  }
}
