import 'package:app_catolica/features/rosario/data/repositories/rosario_repository.dart';

import '../entities/rosario.dart';

class ObtenerContenidoRosarioUseCase {
  final RosarioRepository repository;

  const ObtenerContenidoRosarioUseCase(
    this.repository,
  );

  Future<ContenidoRosario> call() {
    return repository.obtenerContenido();
  }
}