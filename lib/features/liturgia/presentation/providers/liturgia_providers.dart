// lib/features/liturgia/presentation/providers/liturgia_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/liturgia_firestore_datasource.dart';
import '../../data/repositories/liturgia_repository_impl.dart';
import '../../domain/repositories/liturgia_repository.dart';
import '../../domain/usecases/get_liturgia_del_dia_usecase.dart';

final liturgiaFirestoreDataSourceProvider =
    Provider<LiturgiaFirestoreDataSource>(
  (ref) {
    return LiturgiaFirestoreDataSource();
  },
);

final liturgiaRepositoryProvider =
    Provider<LiturgiaRepository>(
  (ref) {
    return LiturgiaRepositoryImpl(
      ref.watch(
        liturgiaFirestoreDataSourceProvider,
      ),
    );
  },
);

final getLiturgiaDelDiaUseCaseProvider =
    Provider<GetLiturgiaDelDiaUseCase>(
  (ref) {
    return GetLiturgiaDelDiaUseCase(
      ref.watch(liturgiaRepositoryProvider),
    );
  },
);

class FechaLiturgiaController
    extends Notifier<DateTime> {
  @override
  DateTime build() {
    return _sinHora(DateTime.now());
  }

  void seleccionarFecha(DateTime fecha) {
    state = _sinHora(fecha);
  }

  void irAlDiaAnterior() {
    state = _sinHora(
      state.subtract(
        const Duration(days: 1),
      ),
    );
  }

  void irAlDiaSiguiente() {
    state = _sinHora(
      state.add(
        const Duration(days: 1),
      ),
    );
  }

  void volverAHoy() {
    state = _sinHora(DateTime.now());
  }

  DateTime _sinHora(DateTime fecha) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
    );
  }
}

final fechaLiturgiaProvider = NotifierProvider<
    FechaLiturgiaController,
    DateTime>(
  FechaLiturgiaController.new,
);

/// Liturgia correspondiente a la fecha seleccionada.
///
/// Devuelve un Either para que la pantalla distinga entre:
/// - lectura disponible;
/// - lectura todavía no sincronizada;
/// - error de permisos;
/// - error de red.
final liturgiaPorFechaProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final fecha = ref.watch(
      fechaLiturgiaProvider,
    );

    final useCase = ref.watch(
      getLiturgiaDelDiaUseCaseProvider,
    );

    return useCase(fecha);
  },
);

/// Se conserva para las pantallas que necesitan consultar
/// exclusivamente el día actual, por ejemplo HomeScreen.
final liturgiaDeHoyProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final ahora = DateTime.now();

    final hoy = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    );

    final useCase = ref.watch(
      getLiturgiaDelDiaUseCaseProvider,
    );

    return useCase(hoy);
  },
);