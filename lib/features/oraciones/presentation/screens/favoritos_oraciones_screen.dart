// lib/features/oraciones/presentation/screens/favoritos_oraciones_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/oracion.dart';
import '../providers/oraciones_providers.dart';
import '../../../../shared/widgets/favorito_button.dart';

class FavoritosOracionesScreen extends ConsumerWidget {
  const FavoritosOracionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oracionesAsync = ref.watch(oracionesStreamProvider);
    final favoritosIds = ref.watch(oracionesFavoritosStreamProvider).value ?? const {};
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Oraciones Favoritas')),
      body: oracionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (todas) {
          final favoritas = <Oracion>[];
          for (final o in todas) {
            if (favoritosIds.contains(o.id)) favoritas.add(o);
          }

          if (favoritas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no has guardado oraciones favoritas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritas.length,
            itemBuilder: (context, index) {
              final oracion = favoritas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: ListTile(
                  title: Text(oracion.titulo),
                  subtitle: Text(OracionesConstants.etiquetaCategoria(oracion.categoria)),
                  trailing: uid == null
                      ? null
                      : FavoritoButton(
                          esFavorito: true,
                          onTap: () =>
                              ref.read(favoritoOracionControllerProvider.notifier).toggle(
                                    uid: uid,
                                    oracionId: oracion.id,
                                    marcarComoFavorito: false,
                                  ),
                        ),
                  onTap: () => context.push('/oraciones/${oracion.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
