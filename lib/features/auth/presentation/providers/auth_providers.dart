// lib/features/auth/presentation/providers/auth_providers.dart
//
// CORRECCIÓN: en Riverpod 3.x, StateNotifier/StateNotifierProvider está
// deprecado. Se reemplaza por Notifier/NotifierProvider (API moderna,
// sin necesidad de build_runner ni codegen).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/user_firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_anonymously_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/link_anonymous_to_google_usecase.dart';
import '../../domain/usecases/link_anonymous_to_email_usecase.dart';

// Datasources
final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDataSource());

final userFirestoreDataSourceProvider =
    Provider((ref) => UserFirestoreDataSource());

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(userFirestoreDataSourceProvider),
  );
});

// Estado reactivo de sesión — usado por el router para proteger rutas
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Usecases
final signInWithEmailUseCaseProvider = Provider(
  (ref) => SignInWithEmailUseCase(ref.watch(authRepositoryProvider)),
);
final signUpWithEmailUseCaseProvider = Provider(
  (ref) => SignUpWithEmailUseCase(ref.watch(authRepositoryProvider)),
);
final signInWithGoogleUseCaseProvider = Provider(
  (ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)),
);
final signInAnonymouslyUseCaseProvider = Provider(
  (ref) => SignInAnonymouslyUseCase(ref.watch(authRepositoryProvider)),
);
final sendPasswordResetUseCaseProvider = Provider(
  (ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);
final signOutUseCaseProvider = Provider(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);
final linkAnonymousToGoogleUseCaseProvider = Provider(
  (ref) => LinkAnonymousToGoogleUseCase(ref.watch(authRepositoryProvider)),
);
final linkAnonymousToEmailUseCaseProvider = Provider(
  (ref) => LinkAnonymousToEmailUseCase(ref.watch(authRepositoryProvider)),
);

/// Controller único para todos los flujos de autenticación.
/// Expone AsyncValue<void> para que la UI reaccione a loading/error
/// de forma uniforme (isLoading, whenOrNull, etc.).
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> signInWithEmail(String email, String password) {
    return _run(() => ref
        .read(signInWithEmailUseCaseProvider)
        .call(email: email, password: password));
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
  }) {
    return _run(() => ref.read(signUpWithEmailUseCaseProvider).call(
          email: email,
          password: password,
          nombre: nombre,
        ));
  }

  Future<bool> signInWithGoogle() {
    return _run(() => ref.read(signInWithGoogleUseCaseProvider).call());
  }

  Future<bool> signInAnonymously() {
    return _run(() => ref.read(signInAnonymouslyUseCaseProvider).call());
  }

  Future<bool> sendPasswordReset(String email) {
    return _run(() =>
        ref.read(sendPasswordResetUseCaseProvider).call(email: email));
  }

  Future<bool> signOut() {
    return _run(() => ref.read(signOutUseCaseProvider).call());
  }

  Future<bool> linkAnonymousToGoogle() {
    return _run(() => ref.read(linkAnonymousToGoogleUseCaseProvider).call());
  }

  Future<bool> linkAnonymousToEmail(String email, String password) {
    return _run(() => ref.read(linkAnonymousToEmailUseCaseProvider).call(
          email: email,
          password: password,
        ));
  }
}

final loginControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
