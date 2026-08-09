// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;

  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
  });

  Future<Either<AuthFailure, UserEntity>> signInWithGoogle();

  Future<Either<AuthFailure, UserEntity>> signInAnonymously();

  Future<Either<AuthFailure, UserEntity>> linkAnonymousToGoogle();

  Future<Either<AuthFailure, UserEntity>> linkAnonymousToEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, Unit>> sendPasswordReset({required String email});

  Future<Either<AuthFailure, Unit>> signOut();

  // --- Añadido en el Módulo 3 (Perfil) ---

  Future<Either<AuthFailure, Unit>> reauthenticateWithPassword(String password);

  Future<Either<AuthFailure, Unit>> reauthenticateWithGoogle();

  Future<Either<AuthFailure, Unit>> updateAuthProfile({
    String? nombre,
    String? fotoUrl,
  });

  Future<Either<AuthFailure, Unit>> changePassword(String newPassword);

  Future<Either<AuthFailure, Unit>> deleteAccount();
}