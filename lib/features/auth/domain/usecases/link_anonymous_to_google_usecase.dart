// lib/features/auth/domain/usecases/link_anonymous_to_google_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LinkAnonymousToGoogleUseCase {
  final AuthRepository repository;
  const LinkAnonymousToGoogleUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call() {
    return repository.linkAnonymousToGoogle();
  }
}
