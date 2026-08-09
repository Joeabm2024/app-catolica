// lib/features/cantos/data/repositories/
// cantos_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException;
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/cantos_failure.dart';
import '../../domain/entities/canto.dart';
import '../../domain/repositories/cantos_repository.dart';
import '../datasources/cantos_firestore_datasource.dart';

class CantosRepositoryImpl implements CantosRepository {
  final CantosFirestoreDataSource _firestoreDataSource;

  CantosRepositoryImpl(
    this._firestoreDataSource,
  );

  CantosFailure _mapException(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const CantosPermisoDenegadoFailure();

        case 'unavailable':
        case 'network-request-failed':
          return const CantosNetworkFailure();

        case 'not-found':
          return const CantoNoEncontradoFailure();

        default:
          return CantosUnknownFailure(
            error.message ?? 'Error de Firebase.',
          );
      }
    }

    return const CantosUnknownFailure();
  }

  @override
  Stream<List<Canto>> watchCantos() {
    return _firestoreDataSource.watchCantos();
  }

  @override
  Future<Either<CantosFailure, Canto>> getCantoById(
    String id,
  ) async {
    try {
      final canto = await _firestoreDataSource.getCantoById(
        id,
      );

      if (canto == null) {
        return left(
          const CantoNoEncontradoFailure(),
        );
      }

      return right(canto);
    } catch (error) {
      return left(
        _mapException(error),
      );
    }
  }

  @override
  Future<Either<CantosFailure, Unit>> toggleFavorito({
    required String uid,
    required String cantoId,
    required bool marcarComoFavorito,
  }) async {
    try {
      if (marcarComoFavorito) {
        await _firestoreDataSource.marcarFavorito(
          uid,
          cantoId,
        );
      } else {
        await _firestoreDataSource.desmarcarFavorito(
          uid,
          cantoId,
        );
      }

      return right(unit);
    } catch (error) {
      return left(
        _mapException(error),
      );
    }
  }

  @override
  Stream<Set<String>> watchFavoritos(
    String uid,
  ) {
    return _firestoreDataSource.watchFavoritos(
      uid,
    );
  }
}