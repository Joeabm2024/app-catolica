// lib/core/errors/liturgia_failure.dart

sealed class LiturgiaFailure {
  final String message;
  const LiturgiaFailure(this.message);
}

/// No es un error real: significa que nadie (admin) ha cargado la
/// liturgia de esa fecha todavía. Se maneja como estado vacío en la UI,
/// no como un SnackBar de error.
class LiturgiaNoDisponibleFailure extends LiturgiaFailure {
  const LiturgiaNoDisponibleFailure()
      : super('Aún no se ha cargado la liturgia de este día.');
}

class LiturgiaPermisoDenegadoFailure extends LiturgiaFailure {
  const LiturgiaPermisoDenegadoFailure()
      : super('No tienes permisos para realizar esta acción.');
}

class LiturgiaNetworkFailure extends LiturgiaFailure {
  const LiturgiaNetworkFailure()
      : super('Sin conexión a internet. Verifica tu red.');
}

class LiturgiaUnknownFailure extends LiturgiaFailure {
  const LiturgiaUnknownFailure([
    super.msg = 'Ocurrió un error inesperado. Intenta de nuevo.',
  ]);
}
