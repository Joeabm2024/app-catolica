import 'package:app_catolica/features/rosario/data/repositories/rosario_repository.dart';

import '../entities/rosario.dart';

class ObtenerMisteriosDelDiaUseCase {
  final RosarioRepository repository;

  const ObtenerMisteriosDelDiaUseCase(
    this.repository,
  );

  Future<TipoMisteriosRosario> call(
    DateTime fecha,
  ) {
    return repository.obtenerMisteriosDelDia(
      fecha,
    );
  }
}