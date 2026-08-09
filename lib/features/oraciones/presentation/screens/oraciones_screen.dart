// lib/features/oraciones/presentation/screens/oraciones_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/oraciones_providers.dart';
import '../widgets/oracion_list_tile.dart';
import '../../../../shared/widgets/filtro_chips.dart';

class OracionesScreen extends ConsumerWidget {
  const OracionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oracionesAsync = ref.watch(oracionesFiltradasProvider);
    final filtro = ref.watch(oracionesFiltroProvider);
    final filtroController = ref.read(oracionesFiltroProvider.notifier);
    final favoritos = ref.watch(oracionesFavoritosStreamProvider).value ?? const {};
    final usuario = ref.watch(authStateProvider).value;
    final esAdmin = usuario?.rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oraciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Favoritas',
            onPressed: () => context.push('/oraciones/favoritos'),
          ),
          if (esAdmin)
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: 'Administrar oraciones',
              onPressed: () => context.push('/oraciones/admin'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: filtroController.setBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FiltroChips(
              opciones: OracionesConstants.categorias
                  .map((c) => FiltroChipOpcion(c.id, c.etiqueta))
                  .toList(),
              seleccionado: filtro.categoria,
              onChanged: filtroController.setCategoria,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: oracionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (oraciones) {
                if (oraciones.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No se encontraron oraciones con estos filtros.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: oraciones.length,
                  itemBuilder: (context, index) {
                    final oracion = oraciones[index];
                    return OracionListTile(
                      oracion: oracion,
                      esFavorito: favoritos.contains(oracion.id),
                      onTap: () => context.push('/oraciones/${oracion.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
