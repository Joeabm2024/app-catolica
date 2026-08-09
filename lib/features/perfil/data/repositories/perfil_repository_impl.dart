// lib/features/perfil/data/repositories/perfil_repository_impl.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../../auth/data/datasources/user_firestore_datasource.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../datasources/storage_datasource.dart';

class PerfilRepositoryImpl implements PerfilRepository {
  final StorageDataSource _storageDs;
  final UserFirestoreDataSource _firestoreDs;

  PerfilRepositoryImpl(this._storageDs, this._firestoreDs);

  AuthFailure _mapException(Object e) {
    if (e is fb.FirebaseAuthException) {
      if (e.code == 'requires-recent-login') {
        return const RequiresRecentLoginFailure();
      }
      return UnknownAuthFailure(e.message ?? 'Error de autenticación.');
    }
    return const UnknownAuthFailure(
      'No se pudo completar la operación. Intenta de nuevo.',
    );
  }

  @override
  Future<Either<AuthFailure, String>> uploadAvatar({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final url = await _storageDs.uploadAvatar(uid, imageFile);
      return right(url);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> updatePreferences({
    required String uid,
    required UserPreferences preferencias,
  }) async {
    try {
      await _firestoreDs.updateUser(uid, {
        'configuracion': preferencias.toMap(),
      });
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> limpiarDatosDeUsuario(String uid) async {
    try {
      await _storageDs.deleteAvatarIfExists(uid);
      await _firestoreDs.deleteUser(uid);
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }
}
