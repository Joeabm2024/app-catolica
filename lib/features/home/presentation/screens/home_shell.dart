// lib/features/home/presentation/screens/home_shell.dart
//
// Contenedor de navegación raíz. Usamos StatefulShellRoute (go_router) para
// que cada pestaña mantenga su propio historial/estado de scroll al
// cambiar entre ellas. Hoy solo hay 2 pestañas; cuando agreguemos Biblia
// u Oraciones como pestañas raíz (en vez de rutas empujadas), solo se
// agrega un StatefulShellBranch más en app_router.dart — este widget no
// cambia.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
