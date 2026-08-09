// lib/features/liturgia/data/repositories/liturgia_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException;
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/liturgia_failure.dart';
import '../../domain/entities/liturgia_del_dia.dart';
import '../../domain/repositories/liturgia_repository.dart';
import '../datasources/liturgia_firestore_datasource.dart';

class LiturgiaRepositoryImpl
    implements LiturgiaRepository {
  final LiturgiaFirestoreDataSource _dataSource;

  LiturgiaRepositoryImpl(this._dataSource);

  @override
  Future<
      Either<
        LiturgiaFailure,
        LiturgiaDelDia
      >> getLiturgiaDelDia(
    DateTime fecha,
  ) async {
    try {
      final resultado =
          await _dataSource.getLiturgiaDelDia(
        fecha,
      );

      if (resultado == null) {
        return left(
          const LiturgiaNoDisponibleFailure(),
        );
      }

      return right(resultado);
    } catch (error) {
      return left(_mapException(error));
    }
  }

  LiturgiaFailure _mapException(
    Object error,
  ) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const LiturgiaPermisoDenegadoFailure();

        case 'unavailable':
        case 'network-request-failed':
          return const LiturgiaNetworkFailure();

        case 'not-found':
          return const LiturgiaNoDisponibleFailure();

        default:
          return LiturgiaUnknownFailure(
            error.message ??
                'Ocurrió un error al consultar Firestore.',
          );
      }
    }

    return LiturgiaUnknownFailure(
      error.toString(),
    );
  }
}