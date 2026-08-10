import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/santoral_local_datasource.dart';
import '../../data/repositories/santoral_repository_impl.dart';
import '../../domain/entities/santo.dart';
import '../../domain/repositories/santoral_repository.dart';
import '../../domain/usecases/obtener_santo_del_dia_usecase.dart';
import '../../domain/usecases/obtener_santos_usecase.dart';

final santoralLocalDataSourceProvider = Provider<SantoralLocalDataSource>((
  ref,
) {
  return SantoralLocalDataSource();
});

final santoralRepositoryProvider = Provider<SantoralRepository>((ref) {
  return SantoralRepositoryImpl(ref.watch(santoralLocalDataSourceProvider));
});

final obtenerSantoDelDiaUseCaseProvider = Provider<ObtenerSantoDelDiaUseCase>((
  ref,
) {
  return ObtenerSantoDelDiaUseCase(ref.watch(santoralRepositoryProvider));
});

final obtenerSantosUseCaseProvider = Provider<ObtenerSantosUseCase>((ref) {
  return ObtenerSantosUseCase(ref.watch(santoralRepositoryProvider));
});

final santoralDeHoyProvider = FutureProvider.autoDispose<Santo?>((ref) async {
  final ahora = DateTime.now();

  final fechaLocal = DateTime(ahora.year, ahora.month, ahora.day);

  return ref.watch(obtenerSantoDelDiaUseCaseProvider).call(fechaLocal);
});

final catalogoSantosProvider = FutureProvider.autoDispose<List<Santo>>((ref) {
  return ref.watch(obtenerSantosUseCaseProvider).call();
});
