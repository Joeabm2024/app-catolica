// lib/features/perfil/domain/usecases/delete_account_usecase.dart
//
// Orquesta el borrado completo: primero limpia Firestore + Storage
// (mientras la sesión sigue siendo válida y las reglas de seguridad lo
// permiten), y solo al final elimina el usuario de Firebase Auth. Si el
// paso de Auth fallara después de limpiar los datos, el usuario quedaría
// sin documento pero con cuenta activa; es un caso borde aceptable para
// esta primera versión — se puede reforzar más adelante con una Cloud
// Function que reaccione a la eliminación real del usuario de Auth.

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/auth_failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../repositories/perfil_repository.dart';

class DeleteAccountUseCase {
  final PerfilRepository perfilRepository;
  final AuthRepository authRepository;
  const DeleteAccountUseCase(this.perfilRepository, this.authRepository);

  Future<Either<AuthFailure, Unit>> call(String uid) async {
    final limpieza = await perfilRepository.limpiarDatosDeUsuario(uid);
    return limpieza.match(
      left,
      (_) => authRepository.deleteAccount(),
    );
  }
}
