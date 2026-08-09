// lib/features/perfil/domain/usecases/update_profile_usecase.dart
//
// Actualiza solo el nombre. Delega en AuthRepository porque el nombre vive
// tanto en Firebase Auth (displayName) como en Firestore (usuarios/{uid});
// AuthRepository.updateAuthProfile ya mantiene ambos sincronizados.

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;
  const UpdateProfileUseCase(this.repository);

  Future<Either<AuthFailure, Unit>> call({required String nombre}) {
    return repository.updateAuthProfile(nombre: nombre);
  }
}
