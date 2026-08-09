// lib/features/auth/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // El redirect de go_router (basado en authStateProvider) decide a dónde
    // navegar en cuanto Firebase resuelve el estado de sesión. Esta pantalla
    // solo se ve durante ese breve instante.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church, size: 72),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
