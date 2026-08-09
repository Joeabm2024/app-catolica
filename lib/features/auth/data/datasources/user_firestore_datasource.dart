// lib/features/auth/data/datasources/user_firestore_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserFirestoreDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  Future<void> createUserIfNotExists(UserModel user) async {
    final docRef = _usuarios.doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(user.toFirestoreOnCreate());
    } else {
      await docRef.update({'ultimoAcceso': FieldValue.serverTimestamp()});
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _usuarios.doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) {
    return _usuarios.doc(uid).delete();
  }
}