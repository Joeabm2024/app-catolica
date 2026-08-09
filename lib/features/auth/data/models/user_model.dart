// lib/features/auth/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../shared/models/user_preferences.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.nombre,
    super.correo,
    super.fotoUrl,
    required super.proveedor,
    required super.esAnonimo,
    required super.emailVerificado,
    super.rol = 'usuario',
    super.preferencias = const UserPreferences(),
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nombre: data['nombre'] ?? 'Usuario',
      correo: data['correo'],
      fotoUrl: data['fotoUrl'],
      proveedor: data['proveedor'] ?? 'anonimo',
      esAnonimo: data['esAnonimo'] ?? true,
      emailVerificado: data['emailVerificado'] ?? false,
      rol: data['rol'] ?? 'usuario',
      // fallback seguro: documentos creados antes de este módulo no tienen
      // el mapa 'configuracion', UserPreferences.fromMap(null) cubre eso.
      preferencias: UserPreferences.fromMap(
        data['configuracion'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'nombre': nombre,
      'correo': correo,
      'fotoUrl': fotoUrl,
      'proveedor': proveedor,
      'esAnonimo': esAnonimo,
      'emailVerificado': emailVerificado,
      'rol': rol,
      'ultimoAcceso': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreOnCreate() {
    return {
      ...toFirestore(),
      'fechaCreacion': FieldValue.serverTimestamp(),
      'configuracion': const UserPreferences().toMap(),
    };
  }
}
