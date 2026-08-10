import '../entities/santo.dart';

abstract class SantoralRepository {
  Future<List<Santo>> obtenerSantos();

  Future<Santo?> obtenerSantoDelDia(DateTime fecha);
}
