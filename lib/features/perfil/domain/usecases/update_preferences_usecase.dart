// lib/features/perfil/domain/usecases/update_preferences_usecase.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../../shared/models/user_preferences.dart';
import '../repositories/perfil_repository.dart';

class UpdatePreferencesUseCase {
  final PerfilRepository repository;
  const UpdatePreferencesUseCase(this.repository);

  Future<Either<AuthFailure, Unit>> call({
    required String uid,
    required UserPreferences preferencias,
  }) {
    return repository.updatePreferences(uid: uid, preferencias: preferencias);
  }
}
