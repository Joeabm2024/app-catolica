// lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;
  const SignInWithEmailUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }
}