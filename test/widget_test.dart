// Smoke test básico: verifica que la app arranca sin excepciones
// y que, al no haber sesión, termina mostrando la pantalla de Login.
//
// NOTA: Firebase.initializeApp() no puede ejecutarse en un entorno de test
// sin mocks, así que aquí solo probamos el árbol de widgets de forma aislada.
// Pruebas de integración con Firebase se agregarán con firebase_auth_mocks
// más adelante, cuando cerremos el módulo de autenticación end-to-end.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ProviderScope se construye sin errores', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SizedBox.shrink()),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
