// lib/features/oraciones/presentation/providers/oraciones_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/oraciones_firestore_datasource.dart';
import '../../data/repositories/oraciones_repository_impl.dart';
import '../../domain/entities/oracion.dart';
import '../../domain/repositories/oraciones_repository.dart';
import '../../domain/usecases/eliminar_oracion_usecase.dart';
import '../../domain/usecases/guardar_oracion_usecase.dart';
import '../../domain/usecases/toggle_favorito_oracion_usecase.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final oracionesFirestoreDataSourceProvider =
    Provider((ref) => OracionesFirestoreDataSource());

final oracionesRepositoryProvider = Provider<OracionesRepository>((ref) {
  return OracionesRepositoryImpl(ref.watch(oracionesFirestoreDataSourceProvider));
});

final guardarOracionUseCaseProvider = Provider(
  (ref) => GuardarOracionUseCase(ref.watch(oracionesRepositoryProvider)),
);
final eliminarOracionUseCaseProvider = Provider(
  (ref) => EliminarOracionUseCase(ref.watch(oracionesRepositoryProvider)),
);
final toggleFavoritoOracionUseCaseProvider = Provider(
  (ref) => ToggleFavoritoOracionUseCase(ref.watch(oracionesRepositoryProvider)),
);

final oracionesStreamProvider = StreamProvider<List<Oracion>>((ref) {
  return ref.watch(oracionesRepositoryProvider).watchOraciones();
});

final oracionesFavoritosStreamProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(oracionesRepositoryProvider).watchFavoritos(uid);
});

/// Estado de filtros de OracionesScreen (categoría + texto de búsqueda).
class OracionesFiltro {
  final String? categoria; // null = todas las categorías
  final String busqueda;

  const OracionesFiltro({this.categoria, this.busqueda = ''});

  OracionesFiltro copyWith({
    String? categoria,
    bool limpiarCategoria = false,
    String? busqueda,
  }) {
    return OracionesFiltro(
      categoria: limpiarCategoria ? null : (categoria ?? this.categoria),
      busqueda: busqueda ?? this.busqueda,
    );
  }
}

class OracionesFiltroController extends Notifier<OracionesFiltro> {
  @override
  OracionesFiltro build() => const OracionesFiltro();

  void setCategoria(String? id) {
    state = id == null
        ? state.copyWith(limpiarCategoria: true)
        : state.copyWith(categoria: id);
  }

  void setBusqueda(String texto) => state = state.copyWith(busqueda: texto);
}

final oracionesFiltroProvider =
    NotifierProvider<OracionesFiltroController, OracionesFiltro>(
  OracionesFiltroController.new,
);

/// Filtrado combinado (categoría + texto) hecho en cliente, mismo enfoque
/// que cantosFiltradosProvider (Módulo 5) — catálogo pequeño, sin
/// necesidad de índices compuestos en Firestore.
final oracionesFiltradasProvider = Provider<AsyncValue<List<Oracion>>>((ref) {
  final oracionesAsync = ref.watch(oracionesStreamProvider);
  final filtro = ref.watch(oracionesFiltroProvider);

  return oracionesAsync.whenData((oraciones) {
    return oraciones.where((o) {
      final coincideCategoria = filtro.categoria == null || o.categoria == filtro.categoria;
      final coincideBusqueda = filtro.busqueda.trim().isEmpty ||
          o.titulo.toLowerCase().contains(filtro.busqueda.trim().toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  });
});

class OracionesAdminController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> guardar(Oracion oracion) async {
    state = const AsyncLoading();
    final result = await ref.read(guardarOracionUseCaseProvider).call(oracion);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }

  Future<bool> eliminar(String id) async {
    state = const AsyncLoading();
    final result = await ref.read(eliminarOracionUseCaseProvider).call(id);
    return result.match(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

final oracionesAdminControllerProvider =
    NotifierProvider<OracionesAdminController, AsyncValue<void>>(
  OracionesAdminController.new,
);

class FavoritoOracionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle({
    required String uid,
    required String oracionId,
    required bool marcarComoFavorito,
  }) async {
    final result = await ref.read(toggleFavoritoOracionUseCaseProvider).call(
          uid: uid,
          oracionId: oracionId,
          marcarComoFavorito: marcarComoFavorito,
        );
    result.match(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

final favoritoOracionControllerProvider =
    NotifierProvider<FavoritoOracionController, AsyncValue<void>>(
  FavoritoOracionController.new,
);
