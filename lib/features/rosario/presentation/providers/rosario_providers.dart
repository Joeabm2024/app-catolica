import 'package:app_catolica/features/rosario/data/repositories/rosario_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/rosario_local_datasource.dart';
import '../../data/repositories/rosario_repository_impl.dart';
import '../../domain/entities/rosario.dart';
import '../../domain/usecases/obtener_contenido_rosario_usecase.dart';
import '../../domain/usecases/obtener_misterios_del_dia_usecase.dart';

final rosarioLocalDataSourceProvider =
    Provider<RosarioLocalDataSource>(
  (ref) {
    return RosarioLocalDataSource();
  },
);

final rosarioRepositoryProvider =
    Provider<RosarioRepository>(
  (ref) {
    return RosarioRepositoryImpl(
      ref.watch(
        rosarioLocalDataSourceProvider,
      ),
    );
  },
);

final obtenerContenidoRosarioUseCaseProvider =
    Provider<ObtenerContenidoRosarioUseCase>(
  (ref) {
    return ObtenerContenidoRosarioUseCase(
      ref.watch(
        rosarioRepositoryProvider,
      ),
    );
  },
);

final obtenerMisteriosDelDiaUseCaseProvider =
    Provider<ObtenerMisteriosDelDiaUseCase>(
  (ref) {
    return ObtenerMisteriosDelDiaUseCase(
      ref.watch(
        rosarioRepositoryProvider,
      ),
    );
  },
);

final contenidoRosarioProvider =
    FutureProvider<ContenidoRosario>(
  (ref) {
    return ref
        .watch(
          obtenerContenidoRosarioUseCaseProvider,
        )
        .call();
  },
);

class TipoMisterioSeleccionadoController
    extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void seleccionar(
    String id,
  ) {
    state = id;
  }

  void usarMisteriosDelDia() {
    state = null;
  }
}

final tipoMisterioSeleccionadoProvider = NotifierProvider<
    TipoMisterioSeleccionadoController,
    String?>(
  TipoMisterioSeleccionadoController.new,
);

final tipoMisteriosActivoProvider =
    Provider<AsyncValue<TipoMisteriosRosario>>(
  (ref) {
    final contenidoAsync = ref.watch(
      contenidoRosarioProvider,
    );

    final idSeleccionado = ref.watch(
      tipoMisterioSeleccionadoProvider,
    );

    return contenidoAsync.whenData(
      (contenido) {
        if (idSeleccionado != null) {
          final tipoManual = contenido.obtenerTipoPorId(
            idSeleccionado,
          );

          if (tipoManual != null) {
            return tipoManual;
          }
        }

        return contenido.obtenerTipoDelDia(
          DateTime.now(),
        );
      },
    );
  },
);
