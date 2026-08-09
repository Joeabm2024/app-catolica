// lib/features/cantos/presentation/providers/
// cantos_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/cantos_firestore_datasource.dart';
import '../../data/repositories/cantos_repository_impl.dart';
import '../../domain/entities/canto.dart';
import '../../domain/repositories/cantos_repository.dart';
import '../../domain/usecases/get_canto_by_id_usecase.dart';
import '../../domain/usecases/toggle_favorito_usecase.dart';

final cantosFirestoreDataSourceProvider =
    Provider<CantosFirestoreDataSource>(
  (ref) {
    return CantosFirestoreDataSource();
  },
);

final cantosRepositoryProvider =
    Provider<CantosRepository>(
  (ref) {
    return CantosRepositoryImpl(
      ref.watch(
        cantosFirestoreDataSourceProvider,
      ),
    );
  },
);

final getCantoByIdUseCaseProvider =
    Provider<GetCantoByIdUseCase>(
  (ref) {
    return GetCantoByIdUseCase(
      ref.watch(cantosRepositoryProvider),
    );
  },
);

final toggleFavoritoUseCaseProvider =
    Provider<ToggleFavoritoUseCase>(
  (ref) {
    return ToggleFavoritoUseCase(
      ref.watch(cantosRepositoryProvider),
    );
  },
);

/// Catálogo de canciones publicadas.
///
/// El datasource ya aplica:
/// publicado == true
final cantosStreamProvider =
    StreamProvider<List<Canto>>(
  (ref) {
    return ref
        .watch(cantosRepositoryProvider)
        .watchCantos();
  },
);

/// IDs de los cantos favoritos del usuario actual.
///
/// Si no hay una sesión autenticada, emite inmediatamente
/// un conjunto vacío para evitar que el provider permanezca
/// indefinidamente en estado loading.
final cantosFavoritosStreamProvider =
    StreamProvider<Set<String>>(
  (ref) {
    final uid = ref.watch(
      authStateProvider.select(
        (authState) => authState.value?.uid,
      ),
    );

    if (uid == null) {
      return Stream.value(
        const <String>{},
      );
    }

    return ref
        .watch(cantosRepositoryProvider)
        .watchFavoritos(uid);
  },
);

/// Estado de los filtros seleccionados en CantosScreen.
class CantosFiltro {
  final String? tiempoLiturgico;
  final String? momentoMisa;
  final String busqueda;

  const CantosFiltro({
    this.tiempoLiturgico,
    this.momentoMisa,
    this.busqueda = '',
  });

  CantosFiltro copyWith({
    String? tiempoLiturgico,
    bool limpiarTiempo = false,
    String? momentoMisa,
    bool limpiarMomento = false,
    String? busqueda,
  }) {
    return CantosFiltro(
      tiempoLiturgico: limpiarTiempo
          ? null
          : tiempoLiturgico ??
              this.tiempoLiturgico,
      momentoMisa: limpiarMomento
          ? null
          : momentoMisa ??
              this.momentoMisa,
      busqueda: busqueda ?? this.busqueda,
    );
  }
}

class CantosFiltroController
    extends Notifier<CantosFiltro> {
  @override
  CantosFiltro build() {
    return const CantosFiltro();
  }

  void setTiempo(String? id) {
    if (id == null) {
      state = state.copyWith(
        limpiarTiempo: true,
      );
      return;
    }

    state = state.copyWith(
      tiempoLiturgico: id,
    );
  }

  void setMomento(String? id) {
    if (id == null) {
      state = state.copyWith(
        limpiarMomento: true,
      );
      return;
    }

    state = state.copyWith(
      momentoMisa: id,
    );
  }

  void setBusqueda(String texto) {
    state = state.copyWith(
      busqueda: texto,
    );
  }

  void limpiarFiltros() {
    state = const CantosFiltro();
  }
}

final cantosFiltroProvider = NotifierProvider<
    CantosFiltroController,
    CantosFiltro>(
  CantosFiltroController.new,
);

/// Lista derivada del catálogo publicado y los filtros.
///
/// Los filtros se ejecutan localmente porque cada canción
/// puede pertenecer a múltiples tiempos y momentos.
final cantosFiltradosProvider =
    Provider<AsyncValue<List<Canto>>>(
  (ref) {
    final cantosAsync = ref.watch(
      cantosStreamProvider,
    );

    final filtro = ref.watch(
      cantosFiltroProvider,
    );

    return cantosAsync.whenData(
      (cantos) {
        final textoBusqueda =
            filtro.busqueda.trim().toLowerCase();

        final resultado = cantos.where(
          (canto) {
            final coincideTiempo =
                filtro.tiempoLiturgico == null ||
                    filtro.tiempoLiturgico ==
                        'todos' ||
                    canto.tiemposLiturgicos.contains(
                      filtro.tiempoLiturgico,
                    ) ||
                    canto.tiemposLiturgicos.contains(
                      'todos',
                    );

            final coincideMomento =
                filtro.momentoMisa == null ||
                    canto.momentosMisa.contains(
                      filtro.momentoMisa,
                    );

            final coincideBusqueda =
                textoBusqueda.isEmpty ||
                    canto.titulo
                        .toLowerCase()
                        .contains(textoBusqueda) ||
                    (canto.autor
                            ?.toLowerCase()
                            .contains(textoBusqueda) ??
                        false);

            return coincideTiempo &&
                coincideMomento &&
                coincideBusqueda;
          },
        ).toList(growable: false);

        resultado.sort(
          (a, b) => a.titulo
              .toLowerCase()
              .compareTo(
                b.titulo.toLowerCase(),
              ),
        );

        return resultado;
      },
    );
  },
);

/// Controla únicamente los favoritos.
///
/// Esta operación no modifica la canción.
class FavoritoController
    extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> toggle({
    required String uid,
    required String cantoId,
    required bool marcarComoFavorito,
  }) async {
    state = const AsyncLoading();

    final resultado = await ref
        .read(toggleFavoritoUseCaseProvider)
        .call(
          uid: uid,
          cantoId: cantoId,
          marcarComoFavorito:
              marcarComoFavorito,
        );

    resultado.match(
      (failure) {
        state = AsyncError(
          failure.message,
          StackTrace.current,
        );
      },
      (_) {
        state = const AsyncData(null);
      },
    );
  }
}

final favoritoControllerProvider = NotifierProvider<
    FavoritoController,
    AsyncValue<void>>(
  FavoritoController.new,
);