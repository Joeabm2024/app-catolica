import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/santo.dart';
import '../providers/santoral_providers.dart';

class SantoDelDiaScreen extends ConsumerWidget {
  const SantoDelDiaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santoAsync = ref.watch(santoralDeHoyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Santo del Día')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(santoralDeHoyProvider);
          await ref.read(santoralDeHoyProvider.future);
        },
        child: santoAsync.when(
          loading: () => const _EstadoCargando(),
          error: (error, stackTrace) {
            return _EstadoError(
              mensaje: error.toString(),
              onReintentar: () {
                ref.invalidate(santoralDeHoyProvider);
              },
            );
          },
          data: (santo) {
            if (santo == null) {
              return const _EstadoSinSanto();
            }

            return _ContenidoSanto(santo: santo);
          },
        ),
      ),
    );
  }
}

class _ContenidoSanto extends StatelessWidget {
  final Santo santo;

  const _ContenidoSanto({required this.santo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _ImagenSanto(santo: santo),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fechaActualEnEspanol(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                santo.nombre,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (santo.nombreSecular != null) ...[
                const SizedBox(height: 4),
                Text(
                  santo.nombreSecular!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.church_outlined, size: 18),
                label: Text(santo.tipoCelebracion),
              ),
              const SizedBox(height: 24),
              _SeccionSantoral(
                icono: Icons.auto_stories_outlined,
                titulo: 'Su historia',
                contenido: santo.resumen,
              ),
              const SizedBox(height: 16),
              _SeccionSantoral(
                icono: Icons.favorite_outline,
                titulo: 'Virtud para hoy',
                contenido: santo.virtud,
                destacada: true,
              ),
              const SizedBox(height: 16),
              _SeccionSantoral(
                icono: Icons.volunteer_activism_outlined,
                titulo: 'Oración',
                contenido: santo.oracion,
              ),
              if (santo.imagenGeneradaConIA) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Esta imagen es una ilustración '
                          'devocional generada con inteligencia '
                          'artificial; no es un retrato histórico.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ImagenSanto extends StatelessWidget {
  final Santo santo;

  const _ImagenSanto({required this.santo});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 3.2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            santo.imagenAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) {
              return const _ImagenNoDisponible();
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x33000000)],
                stops: [0.65, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenNoDisponible extends StatelessWidget {
  const _ImagenNoDisponible();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.church_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SeccionSantoral extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;
  final bool destacada;

  const _SeccionSantoral({
    required this.icono,
    required this.titulo,
    required this.contenido,
    this.destacada = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: destacada
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: destacada
              ? colorScheme.primary.withValues(alpha: 0.25)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contenido,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _EstadoCargando extends StatelessWidget {
  const _EstadoCargando();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EstadoSinSanto extends StatelessWidget {
  const _EstadoSinSanto();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/santos/'
                    'imagen_generica.webp',
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.church_outlined, size: 72);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _fechaActualEnEspanol(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Todavía no hemos agregado una '
                    'celebración para esta fecha.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Continuaremos ampliando el '
                    'calendario del Santoral.',
                    textAlign: TextAlign.center,
                  ),
                ],
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

  const _EstadoError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 56,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No fue posible cargar el Santoral.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: onReintentar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _fechaActualEnEspanol() {
  final fecha = DateTime.now();

  const diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  final diaSemana = diasSemana[fecha.weekday - 1];
  final mes = meses[fecha.month - 1];

  return '${_capitalizar(diaSemana)} '
      '${fecha.day} de $mes de ${fecha.year}';
}

String _capitalizar(String texto) {
  if (texto.isEmpty) {
    return texto;
  }

  return texto[0].toUpperCase() + texto.substring(1);
}
