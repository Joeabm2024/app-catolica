import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/liturgia_model.dart';

class LiturgiaFirestoreDataSource {
  final FirebaseFirestore _firestore;

  LiturgiaFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _firestore.collection('liturgia_diaria');

  Future<LiturgiaModel?> getLiturgiaDelDia(DateTime fecha) async {
    final documento = await _coleccion.doc(idDeFecha(fecha)).get();
    final data = documento.data();
    if (!documento.exists || data == null || data['publicado'] != true) {
      return null;
    }
    return LiturgiaModel.fromFirestore(data, documento.id);
  }

  String idDeFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
