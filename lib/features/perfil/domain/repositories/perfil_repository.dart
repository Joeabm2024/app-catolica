// lib/features/perfil/domain/repositories/perfil_repository.dart

import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../../shared/models/user_preferences.dart';

abstract class PerfilRepository {
  /// Sube la imagen a Firebase Storage (avatars/{uid}.jpg) y retorna la
  /// URL de descarga pública. No actualiza Firebase Auth ni Firestore
  /// directamente — eso lo hace AuthRepository.updateAuthProfile() con
  /// la URL resultante, para mantener una sola fuente de verdad del
  /// perfil (usuarios/{uid}).
  Future<Either<AuthFailure, String>> uploadAvatar({
    required String uid,
    required File imageFile,
  });

  Future<Either<AuthFailure, Unit>> updatePreferences({
    required String uid,
    required UserPreferences preferencias,
  });

  /// Limpia Firestore (documento del usuario) y Storage (avatar, si existe)
  /// ANTES de que se elimine la cuenta de Firebase Auth — deben borrarse
  /// mientras la sesión todavía es válida, porque las reglas de seguridad
  /// exigen request.auth.uid == userId.
  Future<Either<AuthFailure, Unit>> limpiarDatosDeUsuario(String uid);
}
