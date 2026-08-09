// lib/features/auth/domain/usecases/link_anonymous_to_email_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LinkAnonymousToEmailUseCase {
  final AuthRepository repository;
  const LinkAnonymousToEmailUseCase(this.repository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.linkAnonymousToEmail(email: email, password: password);
  }
}
