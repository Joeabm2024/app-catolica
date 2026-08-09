// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/home_providers.dart';
import '../../../../shared/widgets/daily_hero_card.dart';
import '../../../../shared/widgets/guest_banner.dart';
import '../../../../shared/widgets/module_grid_tile.dart';
import '../../../../shared/widgets/section_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final modulos = ref.watch(dashboardModulesProvider);

    final usuario = authState.value;
    final nombre = usuario?.nombre ?? 'Hermano/a';
    final esAnonimo = usuario?.esAnonimo ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $nombre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificaciones',
            onPressed: () {
              // Se conecta con Firebase Cloud Messaging en el módulo
              // dedicado de notificaciones.
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ref.invalidate/refresh de providers de contenido remoto
          // cuando existan (Módulos 5+). Por ahora es un no-op seguro.
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (esAnonimo) const GuestBanner(),
            const DailyHeroCard(),
            const SizedBox(height: 28),
            const SectionTitle(title: 'Explorar'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modulos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final modulo = modulos[index];
                return ModuleGridTile(
                  modulo: modulo,
                  onTap: () => context.push(modulo.ruta),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
