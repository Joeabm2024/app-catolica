// lib/features/perfil/data/datasources/storage_datasource.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageDataSource {
  final FirebaseStorage _storage;

  StorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadAvatar(String uid, File imageFile) async {
    final ref = _storage.ref().child('avatars/$uid.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  /// Best-effort: si el usuario nunca subió avatar, el archivo no existe
  /// y Storage lanza object-not-found — se ignora silenciosamente.
  Future<void> deleteAvatarIfExists(String uid) async {
    try {
      await _storage.ref().child('avatars/$uid.jpg').delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
