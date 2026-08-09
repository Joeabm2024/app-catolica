// lib/features/auth/domain/entities/user_entity.dart

import '../../../../shared/models/user_preferences.dart';

class UserEntity {
  final String uid;
  final String nombre;
  final String? correo;
  final String? fotoUrl;
  final String proveedor; // "google" | "password" | "anonimo"
  final bool esAnonimo;
  final bool emailVerificado;
  final String rol; // "usuario" | "admin"
  final UserPreferences preferencias;

  const UserEntity({
    required this.uid,
    required this.nombre,
    this.correo,
    this.fotoUrl,
    required this.proveedor,
    required this.esAnonimo,
    required this.emailVerificado,
    this.rol = 'usuario',
    this.preferencias = const UserPreferences(),
  });

  UserEntity copyWith({
    String? nombre,
    String? correo,
    String? fotoUrl,
    String? proveedor,
    bool? esAnonimo,
    UserPreferences? preferencias,
  }) {
    return UserEntity(
      uid: uid,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      proveedor: proveedor ?? this.proveedor,
      esAnonimo: esAnonimo ?? this.esAnonimo,
      emailVerificado: emailVerificado,
      rol: rol,
      preferencias: preferencias ?? this.preferencias,
    );
  }
}
