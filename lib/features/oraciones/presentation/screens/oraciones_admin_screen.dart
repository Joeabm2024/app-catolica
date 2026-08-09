// lib/features/oraciones/presentation/screens/oraciones_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/oraciones_providers.dart';

class OracionesAdminScreen extends ConsumerWidget {
  const OracionesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oracionesAsync = ref.watch(oracionesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Oraciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/oraciones/admin/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva oración'),
      ),
      body: oracionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (oraciones) {
          if (oraciones.isEmpty) {
            return const Center(child: Text('Aún no hay oraciones cargadas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: oraciones.length,
            itemBuilder: (context, index) {
              final oracion = oraciones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: ListTile(
                  title: Text(oracion.titulo),
                  subtitle: Text(OracionesConstants.etiquetaCategoria(oracion.categoria)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/oraciones/admin/${oracion.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirmado = await ConfirmDialog.show(
                            context,
                            titulo: 'Eliminar oración',
                            mensaje:
                                '¿Eliminar "${oracion.titulo}"? Esta acción no se puede deshacer.',
                            textoConfirmar: 'Eliminar',
                            esDestructivo: true,
                          );
                          if (confirmado) {
                            await ref
                                .read(oracionesAdminControllerProvider.notifier)
                                .eliminar(oracion.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
