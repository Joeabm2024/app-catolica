// lib/core/router/app_router.dart

import 'dart:async';

import 'package:app_catolica/features/liturgia/presentation/screens/liturgia_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/link_account_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';

import '../../features/perfil/presentation/screens/cambiar_contrasena_screen.dart';
import '../../features/perfil/presentation/screens/editar_perfil_screen.dart';
import '../../features/perfil/presentation/screens/eliminar_cuenta_screen.dart';
import '../../features/perfil/presentation/screens/perfil_screen.dart';
import '../../features/perfil/presentation/screens/preferencias_screen.dart';

import '../../features/cantos/presentation/screens/canto_detalle_screen.dart';
import '../../features/cantos/presentation/screens/cantos_screen.dart';

import '../../features/oraciones/presentation/screens/favoritos_oraciones_screen.dart';
import '../../features/oraciones/presentation/screens/oracion_detalle_screen.dart';
import '../../features/oraciones/presentation/screens/oracion_form_screen.dart';
import '../../features/oraciones/presentation/screens/oraciones_admin_screen.dart';
import '../../features/oraciones/presentation/screens/oraciones_screen.dart';

import '../../features/rosario/presentation/screens/rosario_screen.dart';
import '../../features/rosario/presentation/screens/rosario_guia_screen.dart';

import '../../features/santoral/presentation/screens/santo_del_dia_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _perfilNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isLoggedIn = authState.value != null;

      final currentLocation = state.matchedLocation;

      const publicRoutes = <String>{'/login', '/register', '/forgot-password'};

      if (currentLocation == '/' && isLoading) {
        return null;
      }

      if (currentLocation == '/' && hasError) {
        return '/login';
      }

      if (currentLocation == '/') {
        return isLoggedIn ? '/home' : '/login';
      }

      if (!isLoggedIn && !publicRoutes.contains(currentLocation)) {
        return '/login';
      }

      if (isLoggedIn && publicRoutes.contains(currentLocation)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),

      GoRoute(
        path: '/link-account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const LinkAccountScreen();
        },
      ),

      // Liturgia diaria: solamente lectura desde Firestore.
      GoRoute(
        path: '/liturgia',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const LiturgiaScreen();
        },
      ),

      // Cantos: catÃ¡logo de solo lectura.
      GoRoute(
        path: '/cantos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const CantosScreen();
        },
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final cantoId = state.pathParameters['id'];

              if (cantoId == null || cantoId.trim().isEmpty) {
                return const _RutaInvalidaScreen(
                  mensaje: 'No se proporcionÃ³ un identificador de canto.',
                );
              }

              return CantoDetalleScreen(cantoId: cantoId);
            },
          ),
        ],
      ),

      // Oraciones.
      GoRoute(
        path: '/oraciones',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const OracionesScreen();
        },
        routes: [
          GoRoute(
            path: 'favoritos',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              return const FavoritosOracionesScreen();
            },
          ),
          GoRoute(
            path: 'admin',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              return const OracionesAdminScreen();
            },
            routes: [
              GoRoute(
                path: 'nuevo',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  return const OracionFormScreen();
                },
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  return OracionFormScreen(
                    oracionId: state.pathParameters['id'],
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final oracionId = state.pathParameters['id'];

              if (oracionId == null || oracionId.trim().isEmpty) {
                return const _RutaInvalidaScreen(
                  mensaje: 'No se proporcionÃ³ un identificador de oraciÃ³n.',
                );
              }

              return OracionDetalleScreen(oracionId: oracionId);
            },
          ),
        ],
      ),

      // MÃ³dulos pendientes.
      GoRoute(
        path: '/rosario',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const RosarioScreen();
        },
        routes: [
          GoRoute(
            path: 'guia',
            builder: (context, state) {
              return const RosarioGuiaScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/santoral',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return const SantoDelDiaScreen();
        },
      ),

      // NavegaciÃ³n principal.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return HomeShell(navigationShell: navigationShell);
            },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return const HomeScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _perfilNavigatorKey,
            routes: [
              GoRoute(
                path: '/home/perfil',
                builder: (context, state) {
                  return const PerfilScreen();
                },
                routes: [
                  GoRoute(
                    path: 'editar',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const EditarPerfilScreen();
                    },
                  ),
                  GoRoute(
                    path: 'preferencias',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const PreferenciasScreen();
                    },
                  ),
                  GoRoute(
                    path: 'cambiar-contrasena',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const CambiarContrasenaScreen();
                    },
                  ),
                  GoRoute(
                    path: 'eliminar-cuenta',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const EliminarCuentaScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return _RutaInvalidaScreen(mensaje: 'Ruta no encontrada: ${state.uri}');
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;

  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _stream = stream.asBroadcastStream();

    _subscription = _stream.listen(
      (_) {
        notifyListeners();
      },
      onError: (_) {
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _RutaInvalidaScreen extends StatelessWidget {
  final String mensaje;

  const _RutaInvalidaScreen({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error de navegaciÃ³n')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(mensaje, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
