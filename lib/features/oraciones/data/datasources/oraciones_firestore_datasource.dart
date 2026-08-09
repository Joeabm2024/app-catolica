// lib/features/oraciones/data/datasources/oraciones_firestore_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/oracion_model.dart';

class OracionesFirestoreDataSource {
  final FirebaseFirestore _firestore;

  OracionesFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _oraciones =>
      _firestore.collection('oraciones');

  Stream<List<OracionModel>> watchOraciones() {
    return _oraciones.orderBy('orden').snapshots().map(
          (snap) => snap.docs
              .map((doc) => OracionModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Si [oracion.id] está vacío, crea un documento nuevo con ID
  /// autogenerado; si no, actualiza el existente.
  Future<void> guardarOracion(OracionModel oracion) async {
    if (oracion.id.isEmpty) {
      await _oraciones.add(oracion.toFirestore());
    } else {
      await _oraciones.doc(oracion.id).set(oracion.toFirestore());
    }
  }

  Future<void> eliminarOracion(String id) {
    return _oraciones.doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> _favoritos(String uid) => _firestore
      .collection('usuarios')
      .doc(uid)
      .collection('oraciones_favoritas');

  Future<void> marcarFavorito(String uid, String oracionId) {
    return _favoritos(uid)
        .doc(oracionId)
        .set({'fechaGuardado': FieldValue.serverTimestamp()});
  }

  Future<void> desmarcarFavorito(String uid, String oracionId) {
    return _favoritos(uid).doc(oracionId).delete();
  }

  Stream<Set<String>> watchFavoritos(String uid) {
    return _favoritos(uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }
}
