// lib/features/auth/data/datasources/auth_remote_datasource.dart
//
// NOTA IMPORTANTE (corrección): google_sign_in ^7.0.0 cambió por completo su API.
// Ya NO existe GoogleSignIn() como constructor ni .signIn(). Ahora:
//   - GoogleSignIn.instance es un singleton.
//   - Hay que llamar .initialize() una vez antes de usarlo.
//   - .authenticate() reemplaza a .signIn() (y lanza GoogleSignInException en vez
//     de retornar null si el usuario cancela).
//   - authentication.idToken ahora es síncrono.
//   - El accessToken se obtiene por separado vía authorizationClient.authorizeScopes().

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  AuthRemoteDataSource({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
      // TODO: una vez registres el SHA-1 en Firebase Console y descargues el
      // google-services.json actualizado, coloca aquí el "OAuth 2.0 Web Client ID"
      // (client_type: 3) que aparecerá en ese archivo. Es requerido por
      // Credential Manager en Android para poder obtener el idToken.
      serverClientId: 'TU_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
    _googleSignInInitialized = true;
  }

  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  fb.User? get currentUser => _firebaseAuth.currentUser;

  Future<fb.UserCredential> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb.UserCredential> signUpWithEmail(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb.UserCredential> signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  /// Retorna null si el usuario canceló el flujo de Google.
  Future<fb.UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final credential = await _buildGoogleCredential(googleUser);
      return _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Retorna null si el usuario canceló el flujo de Google.
  Future<fb.UserCredential?> linkWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final credential = await _buildGoogleCredential(googleUser);
      final user = _firebaseAuth.currentUser;
      return user?.linkWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<fb.AuthCredential> _buildGoogleCredential(
    GoogleSignInAccount googleUser,
  ) async {
    final idToken = googleUser.authentication.idToken;
    final authorization = await googleUser.authorizationClient.authorizeScopes(
      ['email', 'profile'],
    );
    return fb.GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  Future<fb.UserCredential> linkWithEmail(String email, String password) {
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final user = _firebaseAuth.currentUser!;
    return user.linkWithCredential(credential);
  }

  Future<void> sendPasswordReset(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_googleSignInInitialized) {
      await _googleSignIn.signOut();
    }
  }

  // --- Añadido en el Módulo 3 (Perfil) ---

  Future<void> updateDisplayName(String nombre) {
    return _firebaseAuth.currentUser!.updateDisplayName(nombre);
  }

  Future<void> updatePhotoUrl(String url) {
    return _firebaseAuth.currentUser!.updatePhotoURL(url);
  }

  /// Requerido por Firebase antes de operaciones sensibles (cambiar
  /// contraseña, eliminar cuenta) si la sesión no es "reciente".
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser!;
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final credential = await _buildGoogleCredential(googleUser);
    await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) {
    return _firebaseAuth.currentUser!.updatePassword(newPassword);
  }

  Future<void> deleteAccount() {
    return _firebaseAuth.currentUser!.delete();
  }
}
