// lib/core/errors/cantos_failure.dart

sealed class CantosFailure {
  final String message;
  const CantosFailure(this.message);
}

class CantoNoEncontradoFailure extends CantosFailure {
  const CantoNoEncontradoFailure() : super('No se encontró este canto.');
}

class CantosPermisoDenegadoFailure extends CantosFailure {
  const CantosPermisoDenegadoFailure()
      : super('No tienes permisos para realizar esta acción.');
}

class CantosNetworkFailure extends CantosFailure {
  const CantosNetworkFailure()
      : super('Sin conexión a internet. Verifica tu red.');
}

class CantosArchivoInvalidoFailure extends CantosFailure {
  const CantosArchivoInvalidoFailure()
      : super('El archivo debe ser un PDF de máximo 15MB.');
}

class CantosUnknownFailure extends CantosFailure {
  const CantosUnknownFailure([
    super.msg = 'Ocurrió un error inesperado. Intenta de nuevo.',
  ]);
}
