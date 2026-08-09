// lib/features/liturgia/presentation/screens/liturgia_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/liturgia_failure.dart';
import '../../../../core/utils/spanish_date_formatter.dart';
import '../../domain/entities/liturgia_del_dia.dart';
import '../providers/liturgia_providers.dart';
import '../widgets/lectura_card.dart';

class LiturgiaScreen extends ConsumerWidget {
  const LiturgiaScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final fechaSeleccionada = ref.watch(
      fechaLiturgiaProvider,
    );

    final liturgiaAsync = ref.watch(
      liturgiaPorFechaProvider,
    );

    final fechaController = ref.read(
      fechaLiturgiaProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liturgia diaria'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.today_outlined,
            ),
            tooltip: 'Volver a hoy',
            onPressed: fechaController.volverAHoy,
          ),
        ],
      ),
      body: Column(
        children: [
          _SelectorFecha(
            fecha: fechaSeleccionada,
            onDiaAnterior:
                fechaController.irAlDiaAnterior,
            onDiaSiguiente:
                fechaController.irAlDiaSiguiente,
            onSeleccionarFecha: () {
              _mostrarSelectorFecha(
                context: context,
                fechaInicial: fechaSeleccionada,
                onFechaSeleccionada:
                    fechaController.seleccionarFecha,
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  liturgiaPorFechaProvider,
                );

                await ref.read(
                  liturgiaPorFechaProvider.future,
                );
              },
              child: liturgiaAsync.when(
                loading: () {
                  return const _EstadoCargando();
                },
                error: (error, stackTrace) {
                  return _EstadoError(
                    mensaje: error.toString(),
                    onReintentar: () {
                      ref.invalidate(
                        liturgiaPorFechaProvider,
                      );
                    },
                  );
                },
                data: (resultado) {
                  return resultado.match(
                    (failure) {
                      if (failure
                          is LiturgiaNoDisponibleFailure) {
                        return _EstadoVacio(
                          fecha: fechaSeleccionada,
                          onDiaAnterior:
                              fechaController
                                  .irAlDiaAnterior,
                          onDiaSiguiente:
                              fechaController
                                  .irAlDiaSiguiente,
                          onReintentar: () {
                            ref.invalidate(
                              liturgiaPorFechaProvider,
                            );
                          },
                        );
                      }

                      return _EstadoError(
                        mensaje: failure.message,
                        onReintentar: () {
                          ref.invalidate(
                            liturgiaPorFechaProvider,
                          );
                        },
                      );
                    },
                    (liturgia) {
                      return _ContenidoLiturgia(
                        liturgia: liturgia,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSelectorFecha({
    required BuildContext context,
    required DateTime fechaInicial,
    required ValueChanged<DateTime>
        onFechaSeleccionada,
  }) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
      helpText: 'Seleccionar fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null) {
      onFechaSeleccionada(fecha);
    }
  }
}

class _SelectorFecha extends StatelessWidget {
  final DateTime fecha;
  final VoidCallback onDiaAnterior;
  final VoidCallback onDiaSiguiente;
  final VoidCallback onSeleccionarFecha;

  const _SelectorFecha({
    required this.fecha,
    required this.onDiaAnterior,
    required this.onDiaSiguiente,
    required this.onSeleccionarFecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            icon: const Icon(
              Icons.chevron_left,
            ),
            tooltip: 'Día anterior',
            onPressed: onDiaAnterior,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSeleccionarFecha,
              icon: const Icon(
                Icons.calendar_month_outlined,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Text(
                  SpanishDateFormatter.longDate(
                    fecha,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(
              Icons.chevron_right,
            ),
            tooltip: 'Día siguiente',
            onPressed: onDiaSiguiente,
          ),
        ],
      ),
    );
  }
}

class _ContenidoLiturgia extends StatelessWidget {
  final LiturgiaDelDia liturgia;

  const _ContenidoLiturgia({
    required this.liturgia,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        36,
      ),
      children: [
        _EncabezadoLecturas(
          fecha: liturgia.fecha,
        ),
        const SizedBox(height: 20),
        LecturaCard(
          titulo: 'Primera lectura',
          icono: Icons.book_outlined,
          lectura: liturgia.primeraLectura,
          inicialmenteExpandida: true,
        ),
        if (liturgia.tieneSalmo)
          LecturaCard(
            titulo: 'Salmo responsorial',
            icono: Icons.music_note_outlined,
            lectura: liturgia.salmoResponsorial!,
          ),
        if (liturgia.tieneSegundaLectura)
          LecturaCard(
            titulo: 'Segunda lectura',
            icono: Icons.book_outlined,
            lectura: liturgia.segundaLectura!,
          ),
        LecturaCard(
          titulo: 'Evangelio',
          icono: Icons.auto_stories_outlined,
          lectura: liturgia.evangelio,
          inicialmenteExpandida: true,
        ),
        const SizedBox(height: 14),
        _InformacionBiblia(
          version: liturgia.versionBiblia,
          fuente: liturgia.fuente,
        ),
      ],
    );
  }
}

class _EncabezadoLecturas extends StatelessWidget {
  final DateTime fecha;

  const _EncabezadoLecturas({
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primary,
            Theme.of(context)
                .colorScheme
                .primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Lecturas del día',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  SpanishDateFormatter.longDate(
                    fecha,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformacionBiblia extends StatelessWidget {
  final VersionBiblia version;
  final FuenteLiturgia fuente;

  const _InformacionBiblia({
    required this.version,
    required this.fuente,
  });

  @override
  Widget build(BuildContext context) {
    final nombreVersion = version.nombre.trim();
    final abreviatura = version.abreviatura.trim();

    final versionVisible = nombreVersion.isNotEmpty
        ? nombreVersion
        : abreviatura;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Información',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (versionVisible.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Versión bíblica: $versionVisible',
            ),
          ],
          if (fuente.nombre.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Fuente: ${fuente.nombre}',
            ),
          ],
        ],
      ),
    );
  }
}

class _EstadoCargando extends StatelessWidget {
  const _EstadoCargando();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final DateTime fecha;
  final VoidCallback onDiaAnterior;
  final VoidCallback onDiaSiguiente;
  final VoidCallback onReintentar;

  const _EstadoVacio({
    required this.fecha,
    required this.onDiaAnterior,
    required this.onDiaSiguiente,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 62,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lecturas no disponibles',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todavía no se han sincronizado '
                      'las lecturas para '
                      '${SpanishDateFormatter.longDate(fecha)}.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.tonalIcon(
                      onPressed: onReintentar,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Reintentar',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onDiaAnterior,
                          icon: const Icon(
                            Icons.chevron_left,
                          ),
                          label: const Text(
                            'Día anterior',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: onDiaSiguiente,
                          icon: const Icon(
                            Icons.chevron_right,
                          ),
                          label: const Text(
                            'Día siguiente',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 58,
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No fue posible cargar '
                      'las lecturas.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.tonalIcon(
                      onPressed: onReintentar,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Reintentar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}