import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/rosario.dart';
import '../providers/rosario_guia_controller.dart';
import '../providers/rosario_providers.dart';

class RosarioScreen extends ConsumerWidget {
  const RosarioScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final contenidoAsync = ref.watch(
      contenidoRosarioProvider,
    );

    final tipoActivoAsync = ref.watch(
      tipoMisteriosActivoProvider,
    );

    final idSeleccionado = ref.watch(
      tipoMisterioSeleccionadoProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Santo Rosario'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            contenidoRosarioProvider,
          );

          await ref.read(
            contenidoRosarioProvider.future,
          );
        },
        child: contenidoAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _EstadoError(
            mensaje: error.toString(),
            onReintentar: () {
              ref.invalidate(
                contenidoRosarioProvider,
              );
            },
          ),
          data: (contenido) {
            return tipoActivoAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => _EstadoError(
                mensaje: error.toString(),
                onReintentar: () {
                  ref.invalidate(
                    contenidoRosarioProvider,
                  );
                },
              ),
              data: (tipoActivo) {
                return _ContenidoRosario(
                  contenido: contenido,
                  tipoActivo: tipoActivo,
                  idSeleccionado:
                      idSeleccionado,
                  onSeleccionarTipo: (id) {
                    ref
                        .read(
                          tipoMisterioSeleccionadoProvider
                              .notifier,
                        )
                        .seleccionar(id);
                  },
                  onUsarMisteriosDelDia: () {
                    ref
                        .read(
                          tipoMisterioSeleccionadoProvider
                              .notifier,
                        )
                        .usarMisteriosDelDia();
                  },
                  onComenzar: () {
                    ref
                        .read(
                          rosarioGuiaControllerProvider
                              .notifier,
                        )
                        .iniciar(
                          contenido: contenido,
                          tipoMisterios:
                              tipoActivo,
                        );

                    context.push(
                      '/rosario/guia',
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ContenidoRosario extends StatelessWidget {
  final ContenidoRosario contenido;
  final TipoMisteriosRosario tipoActivo;
  final String? idSeleccionado;
  final ValueChanged<String> onSeleccionarTipo;
  final VoidCallback onUsarMisteriosDelDia;
  final VoidCallback onComenzar;

  const _ContenidoRosario({
    required this.contenido,
    required this.tipoActivo,
    required this.idSeleccionado,
    required this.onSeleccionarTipo,
    required this.onUsarMisteriosDelDia,
    required this.onComenzar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        36,
      ),
      children: [
        _Encabezado(
          tipoActivo: tipoActivo,
          seleccionAutomatica:
              idSeleccionado == null,
        ),
        const SizedBox(height: 22),
        Text(
          'Selecciona los misterios',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(
                Icons.today_outlined,
                size: 18,
              ),
              label: const Text(
                'Misterios de hoy',
              ),
              selected:
                  idSeleccionado == null,
              onSelected: (_) {
                onUsarMisteriosDelDia();
              },
            ),
            ...contenido.tiposMisterios.map(
              (tipo) {
                return ChoiceChip(
                  avatar: Icon(
                    _iconoTipo(tipo.id),
                    size: 18,
                  ),
                  label: Text(
                    _nombreCorto(tipo.id),
                  ),
                  selected:
                      idSeleccionado ==
                          tipo.id,
                  onSelected: (_) {
                    onSeleccionarTipo(
                      tipo.id,
                    );
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          tipoActivo.nombre,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          tipoActivo.descripcion,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        ...tipoActivo.misterios.map(
          (misterio) {
            return _MisterioCard(
              misterio: misterio,
            );
          },
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onComenzar,
          icon: const Icon(
            Icons.play_arrow_rounded,
          ),
          label: const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Text(
              'Comenzar el Rosario',
            ),
          ),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  final TipoMisteriosRosario tipoActivo;
  final bool seleccionAutomatica;

  const _Encabezado({
    required this.tipoActivo,
    required this.seleccionAutomatica,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primary,
            Theme.of(context)
                .colorScheme
                .tertiary,
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.radio_button_checked,
            color: Theme.of(context)
                .colorScheme
                .onPrimary,
            size: 38,
          ),
          const SizedBox(height: 14),
          Text(
            seleccionAutomatica
                ? 'Misterios para hoy'
                : 'Selección manual',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tipoActivo.nombre,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary,
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _MisterioCard extends StatelessWidget {
  final MisterioRosario misterio;

  const _MisterioCard({
    required this.misterio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Text(
                misterio.numero.toString(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    misterio.nombre,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    misterio.citaBiblica,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    misterio.meditacion,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _EstadoError({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.error_outline,
          color: Colors.redAccent,
          size: 56,
        ),
        const SizedBox(height: 16),
        const Text(
          'No fue posible cargar el Rosario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mensaje,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onReintentar,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}

IconData _iconoTipo(String id) {
  switch (id) {
    case 'gozosos':
      return Icons.child_care_outlined;
    case 'dolorosos':
      return Icons.favorite_border;
    case 'gloriosos':
      return Icons.wb_sunny_outlined;
    case 'luminosos':
      return Icons.light_mode_outlined;
    default:
      return Icons.circle_outlined;
  }
}

String _nombreCorto(String id) {
  switch (id) {
    case 'gozosos':
      return 'Gozosos';
    case 'dolorosos':
      return 'Dolorosos';
    case 'gloriosos':
      return 'Gloriosos';
    case 'luminosos':
      return 'Luminosos';
    default:
      return id;
  }
}
