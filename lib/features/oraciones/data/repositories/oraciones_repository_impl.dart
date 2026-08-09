// lib/features/oraciones/data/repositories/oraciones_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/cantos_failure.dart';
import '../../domain/entities/oracion.dart';
import '../../domain/repositories/oraciones_repository.dart';
import '../datasources/oraciones_firestore_datasource.dart';
import '../models/oracion_model.dart';

class OracionesRepositoryImpl implements OracionesRepository {
  final OracionesFirestoreDataSource _firestoreDs;

  OracionesRepositoryImpl(this._firestoreDs);

  CantosFailure _mapException(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return const CantosPermisoDenegadoFailure();
        case 'unavailable':
        case 'network-request-failed':
          return const CantosNetworkFailure();
        default:
          return CantosUnknownFailure(e.message ?? 'Error de Firebase.');
      }
    }
    return const CantosUnknownFailure();
  }

  @override
  Stream<List<Oracion>> watchOraciones() => _firestoreDs.watchOraciones();

  @override
  Future<Either<CantosFailure, Unit>> guardarOracion(Oracion oracion) async {
    try {
      await _firestoreDs.guardarOracion(OracionModel.fromEntity(oracion));
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<CantosFailure, Unit>> eliminarOracion(String id) async {
    try {
      await _firestoreDs.eliminarOracion(id);
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Future<Either<CantosFailure, Unit>> toggleFavorito({
    required String uid,
    required String oracionId,
    required bool marcarComoFavorito,
  }) async {
    try {
      if (marcarComoFavorito) {
        await _firestoreDs.marcarFavorito(uid, oracionId);
      } else {
        await _firestoreDs.desmarcarFavorito(uid, oracionId);
      }
      return right(unit);
    } catch (e) {
      return left(_mapException(e));
    }
  }

  @override
  Stream<Set<String>> watchFavoritos(String uid) =>
      _firestoreDs.watchFavoritos(uid);
}
