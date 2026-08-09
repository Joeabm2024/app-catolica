// lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  const SignUpWithEmailUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
    required String nombre,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      nombre: nombre,
    );
  }
}
