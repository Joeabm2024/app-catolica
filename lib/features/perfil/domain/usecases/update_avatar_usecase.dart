// lib/features/perfil/domain/usecases/update_avatar_usecase.dart

import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../repositories/perfil_repository.dart';

class UpdateAvatarUseCase {
  final PerfilRepository perfilRepository;
  final AuthRepository authRepository;
  const UpdateAvatarUseCase(this.perfilRepository, this.authRepository);

  Future<Either<AuthFailure, Unit>> call({
    required String uid,
    required File imageFile,
  }) async {
    final uploadResult = await perfilRepository.uploadAvatar(
      uid: uid,
      imageFile: imageFile,
    );
    return uploadResult.match(
      left,
      (url) => authRepository.updateAuthProfile(fotoUrl: url),
    );
  }
}
