// lib/features/oraciones/presentation/screens/oracion_detalle_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/oracion.dart';
import '../providers/oraciones_providers.dart';
import '../../../../shared/widgets/favorito_button.dart';

class OracionDetalleScreen extends ConsumerWidget {
  final String oracionId;

  const OracionDetalleScreen({super.key, required this.oracionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oracionesAsync = ref.watch(oracionesStreamProvider);
    final favoritos = ref.watch(oracionesFavoritosStreamProvider).value ?? const {};
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Oración')),
      body: oracionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (oraciones) {
          Oracion? oracion;
          for (final o in oraciones) {
            if (o.id == oracionId) {
              oracion = o;
              break;
            }
          }
          if (oracion == null) {
            return const Center(child: Text('Esta oración ya no está disponible.'));
          }
          final oracionEncontrada = oracion;
          final esFavorito = favoritos.contains(oracionEncontrada.id);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          oracionEncontrada.titulo,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          OracionesConstants.etiquetaCategoria(oracionEncontrada.categoria),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (uid != null)
                    FavoritoButton(
                      esFavorito: esFavorito,
                      onTap: () => ref.read(favoritoOracionControllerProvider.notifier).toggle(
                            uid: uid,
                            oracionId: oracionEncontrada.id,
                            marcarComoFavorito: !esFavorito,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                oracionEncontrada.texto,
                style: const TextStyle(fontSize: 16, height: 1.7),
              ),
            ],
          );
        },
      ),
    );
  }
}
