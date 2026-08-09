// lib/core/errors/auth_failure.dart

sealed class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Correo o contraseña incorrectos.');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('No existe una cuenta con este correo.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('La contraseña es demasiado débil. Usa al menos 8 caracteres.');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Ya existe una cuenta con este correo.');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('El correo electrónico no es válido.');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Sin conexión a internet. Verifica tu red.');
}

class GoogleSignInCancelledFailure extends AuthFailure {
  const GoogleSignInCancelledFailure() : super('Inicio de sesión con Google cancelado.');
}

class CredentialAlreadyInUseFailure extends AuthFailure {
  const CredentialAlreadyInUseFailure()
      : super('Esta cuenta ya está vinculada a otro usuario.');
}

class RequiresRecentLoginFailure extends AuthFailure {
  const RequiresRecentLoginFailure()
      : super('Por seguridad, vuelve a iniciar sesión antes de continuar.');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([super.msg = 'Ocurrió un error inesperado. Intenta de nuevo.']);
}