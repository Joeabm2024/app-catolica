import 'package:app_catolica/features/rosario/data/repositories/rosario_repository.dart';

import '../../domain/entities/rosario.dart';
import '../datasources/rosario_local_datasource.dart';

class RosarioRepositoryImpl implements RosarioRepository {
  final RosarioLocalDataSource _dataSource;

  RosarioRepositoryImpl(this._dataSource);

  @override
  Future<ContenidoRosario> obtenerContenido() {
    return _dataSource.cargarContenido();
  }

  @override
  Future<TipoMisteriosRosario> obtenerMisteriosDelDia(
    DateTime fecha,
  ) async {
    final contenido = await _dataSource.cargarContenido();

    return contenido.obtenerTipoDelDia(fecha);
  }

  @override
  Future<TipoMisteriosRosario?> obtenerMisteriosPorId(
    String id,
  ) async {
    final contenido = await _dataSource.cargarContenido();

    return contenido.obtenerTipoPorId(id);
  }
}