import '../entities/santo.dart';
import '../repositories/santoral_repository.dart';

class ObtenerSantosUseCase {
  final SantoralRepository repository;

  const ObtenerSantosUseCase(this.repository);

  Future<List<Santo>> call() {
    return repository.obtenerSantos();
  }
}
