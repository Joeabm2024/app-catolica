import '../entities/santo.dart';
import '../repositories/santoral_repository.dart';

class ObtenerSantoDelDiaUseCase {
  final SantoralRepository repository;

  const ObtenerSantoDelDiaUseCase(this.repository);

  Future<Santo?> call(DateTime fecha) {
    return repository.obtenerSantoDelDia(fecha);
  }
}
