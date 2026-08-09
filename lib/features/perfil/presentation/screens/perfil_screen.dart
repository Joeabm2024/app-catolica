// lib/features/perfil/presentation/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/profile_menu_tile.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final usuario = authState.value;
    final controller = ref.read(loginControllerProvider.notifier);
    final isLoading = ref.watch(loginControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/home/perfil/editar'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage: usuario?.fotoUrl != null
                          ? NetworkImage(usuario!.fotoUrl!)
                          : null,
                      child: usuario?.fotoUrl == null
                          ? const Icon(Icons.person,
                              size: 32, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario?.nombre ?? 'Usuario',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (usuario?.correo != null)
                            Text(
                              usuario!.correo!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          if (usuario?.esAnonimo == true)
                            const Text(
                              'Cuenta de invitado',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ProfileMenuTile(
              icono: Icons.tune,
              titulo: 'Preferencias',
              subtitulo: 'Tema, idioma, notificaciones',
              onTap: () => context.push('/home/perfil/preferencias'),
            ),
            if (usuario?.proveedor == 'password')
              ProfileMenuTile(
                icono: Icons.lock_outline,
                titulo: 'Cambiar contraseña',
                onTap: () => context.push('/home/perfil/cambiar-contrasena'),
              ),
            ProfileMenuTile(
              icono: Icons.delete_outline,
              titulo: 'Eliminar cuenta',
              color: AppColors.error,
              onTap: () => context.push('/home/perfil/eliminar-cuenta'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isLoading ? null : () => controller.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
