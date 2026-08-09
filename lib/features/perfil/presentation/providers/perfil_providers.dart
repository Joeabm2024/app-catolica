// lib/features/perfil/presentation/providers/perfil_providers.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

final storageDataSourceProvider = Provider((ref) => StorageDataSource());

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  return PerfilRepositoryImpl(
    ref.watch(storageDataSourceProvider),
    ref.watch(userFirestoreDataSourceProvider),
  );
});

final updateProfileUseCaseProvider = Provider(
  (ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)),
);
final updateAvatarUseCaseProvider = Provider(
  (ref) => UpdateAvatarUseCase(
    ref.watch(perfilRepositoryProvider),
    ref.watch(authRepositoryProvider),
  ),
);
final updatePreferencesUseCaseProvider = Provider(
  (ref) => UpdatePreferencesUseCase(ref.watch(perfilRepositoryProvider)),
);
final changePasswordUseCaseProvider = Provider(
  (ref) => ChangePasswordUseCase(ref.watch(authRepositoryProvider)),
);
final deleteAccountUseCaseProvider = Provider(
  (ref) => DeleteAccountUseCase(
    ref.watch(perfilRepositoryProvider),
    ref.watch(authRepositoryProvider),
  ),
);

class PerfilController extends Notifier<AsyncValue<void>> {
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

  Future<bool> updateProfile(String nombre) {
    return _run(
      () => ref.read(updateProfileUseCaseProvider).call(nombre: nombre),
    );
  }

  Future<bool> updateAvatar(String uid, File imageFile) {
    return _run(() => ref
        .read(updateAvatarUseCaseProvider)
        .call(uid: uid, imageFile: imageFile));
  }

  Future<bool> updatePreferences(String uid, UserPreferences preferencias) {
    return _run(() => ref.read(updatePreferencesUseCaseProvider).call(
          uid: uid,
          preferencias: preferencias,
        ));
  }

  Future<bool> reauthenticateWithPassword(String password) {
    return _run(() => ref
        .read(authRepositoryProvider)
        .reauthenticateWithPassword(password));
  }

  Future<bool> reauthenticateWithGoogle() {
    return _run(
      () => ref.read(authRepositoryProvider).reauthenticateWithGoogle(),
    );
  }

  Future<bool> changePassword(String newPassword) {
    return _run(() => ref.read(changePasswordUseCaseProvider).call(newPassword));
  }

  Future<bool> deleteAccount(String uid) {
    return _run(() => ref.read(deleteAccountUseCaseProvider).call(uid));
  }
}

final perfilControllerProvider =
    NotifierProvider<PerfilController, AsyncValue<void>>(
  PerfilController.new,
);
