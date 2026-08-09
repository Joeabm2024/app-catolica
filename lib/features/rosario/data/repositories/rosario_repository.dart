import 'package:app_catolica/features/rosario/domain/entities/rosario.dart';


abstract class RosarioRepository {
  Future<ContenidoRosario> obtenerContenido();

  Future<TipoMisteriosRosario> obtenerMisteriosDelDia(
    DateTime fecha,
  );

  Future<TipoMisteriosRosario?> obtenerMisteriosPorId(
    String id,
  );
}