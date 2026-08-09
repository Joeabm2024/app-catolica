// lib/shared/models/user_preferences.dart
//
// Vive en shared/ (no en features/perfil) porque UserEntity (features/auth)
// también la referencia, y no queremos que 'auth' dependa de 'perfil' —
// eso invertiría la jerarquía de features.

class UserPreferences {
  final String idioma; // "es" | "en"
  final bool temaOscuro;
  final bool notificacionesActivas;

  const UserPreferences({
    this.idioma = 'es',
    this.temaOscuro = false,
    this.notificacionesActivas = true,
  });

  UserPreferences copyWith({
    String? idioma,
    bool? temaOscuro,
    bool? notificacionesActivas,
  }) {
    return UserPreferences(
      idioma: idioma ?? this.idioma,
      temaOscuro: temaOscuro ?? this.temaOscuro,
      notificacionesActivas:
          notificacionesActivas ?? this.notificacionesActivas,
    );
  }

  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPreferences();
    return UserPreferences(
      idioma: map['idioma'] ?? 'es',
      temaOscuro: map['temaOscuro'] ?? false,
      notificacionesActivas: map['notificacionesActivas'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idioma': idioma,
      'temaOscuro': temaOscuro,
      'notificacionesActivas': notificacionesActivas,
    };
  }
}
