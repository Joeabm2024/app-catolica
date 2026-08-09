// lib/features/auth/domain/usecases/sign_in_anonymously_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymouslyUseCase {
  final AuthRepository repository;
  const SignInAnonymouslyUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call() {
    return repository.signInAnonymously();
  }
}