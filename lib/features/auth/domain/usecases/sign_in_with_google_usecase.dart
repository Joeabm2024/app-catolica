// lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  const SignInWithGoogleUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}
