import '../../domain/entities/santo.dart';
import '../../domain/repositories/santoral_repository.dart';
import '../datasources/santoral_local_datasource.dart';

class SantoralRepositoryImpl implements SantoralRepository {
  final SantoralLocalDataSource _dataSource;

  const SantoralRepositoryImpl(this._dataSource);

  @override
  Future<List<Santo>> obtenerSantos() async {
    return _dataSource.obtenerSantos();
  }

  @override
  Future<Santo?> obtenerSantoDelDia(DateTime fecha) async {
    return _dataSource.obtenerSantoDelDia(fecha);
  }
}
