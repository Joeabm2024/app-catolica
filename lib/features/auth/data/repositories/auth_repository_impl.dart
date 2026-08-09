// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_firestore_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final UserFirestoreDataSource _firestoreDs;

  AuthRepositoryImpl(this._remote, this._firestoreDs);

  UserModel _mapFirebaseUser(fb.User user, {required String proveedor}) {
    return UserModel(
      uid: user.uid,
      nombre: user.displayName ?? user.email?.split('@').first ?? 'Invitado',
      correo: user.email,
      fotoUrl: user.photoURL,
      proveedor: proveedor,
      esAnonimo: user.isAnonymous,
      emailVerificado: user.emailVerified,
    );
  }

  AuthFailure _mapException(Object e) {
    if (e is fb.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return const UserNotFoundFailure();
        case 'wrong-password':
        case 'invalid-credential':
          return const InvalidCredentialsFailure();
        case 'weak-password':
          return const WeakPasswordFailure();
        case 'email-already-in-use':
          return const EmailAlreadyInUseFailure();
        case 'invalid-email':
          return const InvalidEmailFailure();
        case 'credential-already-in-use':
          return const CredentialAlreadyInUseFailure();
        case 'network-request-failed':
          return const NetworkFailure();
        case 'requires-recent-login':
          return const RequiresRecentLoginFailure();
        default:
          return UnknownAuthFailure(e.message ?? 'Error de autenticación.');
      }
    }
    return const UnknownAuthFailure();
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remote.authStateChanges.asyncMap((user) async {
        if (user == null) return null;
        final proveedorBase = user.isAnonymous ? 'anonimo' : 'password';
        try {
          // Timeout defensivo: si Firestore está lento/caído, no dejamos
          // que la app se quede colgada en el Splash para siempre — a los
          // 8s se sigue con los datos básicos de Firebase Auth, que ya son
          // suficientes para navegar a Home. El documento se sincroniza
          // solo en el próximo login o acción que lo actualice.
          final fromFirestore = await _firestoreDs
              .getUser(user.uid)
              .timeout(const Duration(seconds: 8));
          return fromFirestore ?? _mapFirebaseUser(user, proveedor: proveedorBase);
        } catch (_) {
          return _mapFirebaseUser(user, proveedor: proveedorBase);
        }
      });

  @override
  UserEntity? get currentUser {
    final user = _remote.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user, proveedor: user.isAnonymous ? 'anonimo' : 'password');
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _remote.signInWithEmail(email, password);
      final userModel = _mapFirebaseUser(cred.user!, proveedor: 'password');
      await _firestoreDs.createUserIfNotExists(userModel);
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final cred = await _remote.signUpWithEmail(email, password);
      await cred.user?.updateDisplayName(nombre);
      await cred.user?.sendEmailVerification();
      final userModel = UserModel(
        uid: cred.user!.uid,
        nombre: nombre,
        correo: email,
        proveedor: 'password',
        esAnonimo: false,
        emailVerificado: false,
      );
      await _firestoreDs.createUserIfNotExists(userModel);
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle() async {
    try {
      final cred = await _remote.signInWithGoogle();
      if (cred == null) return left(const GoogleSignInCancelledFailure());
      final userModel = _mapFirebaseUser(cred.user!, proveedor: 'google');
      await _firestoreDs.createUserIfNotExists(userModel);
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInAnonymously() async {
    try {
      final cred = await _remote.signInAnonymously();
      final userModel = _mapFirebaseUser(cred.user!, proveedor: 'anonimo');
      await _firestoreDs.createUserIfNotExists(userModel);
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> linkAnonymousToGoogle() async {
    try {
      final cred = await _remote.linkWithGoogle();
      if (cred == null) return left(const GoogleSignInCancelledFailure());
      final userModel = _mapFirebaseUser(cred.user!, proveedor: 'google');
      await _firestoreDs.updateUser(userModel.uid, {
        'proveedor': 'google',
        'esAnonimo': false,
        'nombre': userModel.nombre,
        'correo': userModel.correo,
        'fotoUrl': userModel.fotoUrl,
      });
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> linkAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _remote.linkWithEmail(email, password);
      final userModel = _mapFirebaseUser(cred.user!, proveedor: 'password');
      await _firestoreDs.updateUser(userModel.uid, {
        'proveedor': 'password',
        'esAnonimo': false,
        'correo': email,
      });
      return right(userModel);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordReset({required String email}) async {
    try {
      await _remote.sendPasswordReset(email);
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      await _remote.signOut();
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  // --- Añadido en el Módulo 3 (Perfil) ---

  @override
  Future<Either<AuthFailure, Unit>> reauthenticateWithPassword(
    String password,
  ) async {
    try {
      await _remote.reauthenticateWithPassword(password);
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> reauthenticateWithGoogle() async {
    try {
      await _remote.reauthenticateWithGoogle();
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> updateAuthProfile({
    String? nombre,
    String? fotoUrl,
  }) async {
    try {
      if (nombre != null) await _remote.updateDisplayName(nombre);
      if (fotoUrl != null) await _remote.updatePhotoUrl(fotoUrl);

      final uid = _remote.currentUser!.uid;
      final data = <String, dynamic>{
        'nombre': ?nombre,
        'fotoUrl': ?fotoUrl,
      };
      if (data.isNotEmpty) {
        await _firestoreDs.updateUser(uid, data);
      }
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> changePassword(String newPassword) async {
    try {
      await _remote.updatePassword(newPassword);
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }
}