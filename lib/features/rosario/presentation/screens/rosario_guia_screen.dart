import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/rosario_guia_controller.dart';

class RosarioGuiaScreen extends ConsumerWidget {
  const RosarioGuiaScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final estado = ref.watch(
      rosarioGuiaControllerProvider,
    );

    final controller = ref.read(
      rosarioGuiaControllerProvider.notifier,
    );

    final paso = estado.pasoActual;

    if (!estado.iniciado || paso == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Santo Rosario'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  size: 58,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Primero selecciona los misterios '
                  'que deseas rezar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    context.go('/rosario');
                  },
                  child: const Text(
                    'Seleccionar misterios',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          estado.tipoMisteriosNombre ??
              'Santo Rosario',
        ),
        actions: [
          IconButton(
            onPressed: () {
              _confirmarReinicio(
                context: context,
                onConfirmar: controller.reiniciar,
              );
            },
            icon: const Icon(
              Icons.restart_alt,
            ),
            tooltip: 'Reiniciar Rosario',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: estado.progreso,
              minHeight: 7,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Paso ${estado.indiceActual + 1} '
                      'de ${estado.pasos.length}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ),
                  Text(
                    '${(estado.progreso * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24,
                ),
                child: Column(
                  children: [
                    _IconoPaso(
                      tipo: paso.tipo,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      paso.titulo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    if (paso.numeroMisterio !=
                        null) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          'Misterio '
                          '${paso.numeroMisterio}',
                        ),
                      ),
                    ],
                    if (paso.esAveMaria) ...[
                      const SizedBox(height: 22),
                      _ContadorCuentas(
                        actual:
                            paso.repeticionActual ??
                                1,
                        total:
                            paso.totalRepeticiones ??
                                10,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: SelectableText(
                        paso.texto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BarraNavegacion(
              estado: estado,
              onAnterior: controller.retroceder,
              onSiguiente: controller.avanzar,
              onFinalizar: () {
                controller.finalizar();
                context.go('/rosario');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarReinicio({
    required BuildContext context,
    required VoidCallback onConfirmar,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reiniciar Rosario',
          ),
          content: const Text(
            'El progreso volverá a la '
            'primera oración.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      onConfirmar();
    }
  }
}

class _IconoPaso extends StatelessWidget {
  final TipoPasoRosario tipo;

  const _IconoPaso({
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icono;

    switch (tipo) {
      case TipoPasoRosario.oracion:
        icono = Icons.menu_book_outlined;
      case TipoPasoRosario.anuncioMisterio:
        icono = Icons.auto_awesome_outlined;
      case TipoPasoRosario.aveMaria:
        icono = Icons.circle_outlined;
      case TipoPasoRosario.finalizado:
        icono = Icons.check_circle_outline;
    }

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icono,
        size: 40,
        color:
            Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ContadorCuentas extends StatelessWidget {
  final int actual;
  final int total;

  const _ContadorCuentas({
    required this.actual,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$actual de $total',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 13),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 9,
          children: List.generate(
            total,
            (indice) {
              final numero = indice + 1;
              final completada = numero < actual;
              final activa = numero == actual;

              return AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                width: activa ? 30 : 22,
                height: activa ? 30 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completada || activa
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                  border: activa
                      ? Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          width: 4,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BarraNavegacion extends StatelessWidget {
  final EstadoGuiaRosario estado;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;
  final VoidCallback onFinalizar;

  const _BarraNavegacion({
    required this.estado,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: estado.puedeRetroceder
                ? onAnterior
                : null,
            icon: const Icon(
              Icons.arrow_back,
            ),
            label: const Text('Anterior'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: estado.estaFinalizado
                  ? onFinalizar
                  : onSiguiente,
              icon: Icon(
                estado.estaFinalizado
                    ? Icons.check
                    : Icons.arrow_forward,
              ),
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Text(
                  estado.estaFinalizado
                      ? 'Finalizar'
                      : 'Siguiente',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
