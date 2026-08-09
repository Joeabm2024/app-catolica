// lib/features/cantos/data/datasources/
// cantos_firestore_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/canto_model.dart';

class CantosFirestoreDataSource {
  final FirebaseFirestore _firestore;

  CantosFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _cantos {
    return _firestore.collection('cantos');
  }

  CollectionReference<Map<String, dynamic>>
      _favoritos(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('cantos_favoritos');
  }

  /// Escucha únicamente las canciones autorizadas para
  /// mostrarse en la aplicación.
Stream<List<CantoModel>> watchCantos() {
  return _cantos
      .where(
        'publicado',
        isEqualTo: true,
      )
      .snapshots()
      .map(
        (snapshot) {
          final cantos = snapshot.docs
              .map(
                (document) {
                  return CantoModel.fromFirestore(
                    document.data(),
                    document.id,
                  );
                },
              )
              .toList(growable: false);

          cantos.sort(
            (a, b) {
              return a.titulo
                  .toLowerCase()
                  .compareTo(
                    b.titulo.toLowerCase(),
                  );
            },
          );

          return cantos;
        },
      );
}

  /// Obtiene una canción por ID.
  ///
  /// Aunque las reglas de Firestore también impedirán leer
  /// canciones no publicadas, se repite la comprobación aquí
  /// como protección adicional.
  Future<CantoModel?> getCantoById(
    String id,
  ) async {
    final document = await _cantos.doc(id).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    final canto = CantoModel.fromFirestore(
      data,
      document.id,
    );

    if (!canto.publicado) {
      return null;
    }

    return canto;
  }

  /// Marca una canción publicada como favorita.
  Future<void> marcarFavorito(
    String uid,
    String cantoId,
  ) {
    return _favoritos(uid).doc(cantoId).set({
      'cantoId': cantoId,
      'fechaGuardado': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina una canción de los favoritos del usuario.
  Future<void> desmarcarFavorito(
    String uid,
    String cantoId,
  ) {
    return _favoritos(uid)
        .doc(cantoId)
        .delete();
  }

  /// Escucha los identificadores de las canciones favoritas.
  Stream<Set<String>> watchFavoritos(
    String uid,
  ) {
    return _favoritos(uid)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) => document.id,
                )
                .toSet();
          },
        );
  }
}