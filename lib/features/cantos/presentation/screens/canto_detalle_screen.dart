import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/cantos_constants.dart';
import '../../../../shared/widgets/favorito_button.dart';
import '../../../../shared/widgets/pdf_download_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/canto.dart';
import '../../domain/services/transpositor_acordes.dart';
import '../providers/cantos_providers.dart';

class CantoDetalleScreen extends ConsumerStatefulWidget {
  final String cantoId;

  const CantoDetalleScreen({
    super.key,
    required this.cantoId,
  });

  @override
  ConsumerState<CantoDetalleScreen> createState() {
    return _CantoDetalleScreenState();
  }
}

class _CantoDetalleScreenState
    extends ConsumerState<CantoDetalleScreen> {
  String? _tonalidadSeleccionada;
  bool _mostrarAcordes = true;

  @override
  Widget build(BuildContext context) {
    final cantosAsync = ref.watch(cantosStreamProvider);
    final favoritos =
        ref.watch(cantosFavoritosStreamProvider).value ??
            <String>{};

    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canto'),
      ),
      body: cantosAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _VistaError(
            mensaje: error.toString(),
            onReintentar: () {
              ref.invalidate(cantosStreamProvider);
            },
          );
        },
        data: (cantos) {
          final canto = _buscarCanto(cantos);

          if (canto == null) {
            return const Center(
              child: Text(
                'Este canto ya no está disponible.',
              ),
            );
          }

          final tonalidadOriginal =
              _obtenerTonalidadOriginal(canto);

          _tonalidadSeleccionada ??= tonalidadOriginal;

          final tonalidadActual =
              _tonalidadSeleccionada ?? tonalidadOriginal;

          final contenidoTranspuesto =
              TranspositorAcordes.transponer(
            contenido: canto.letra,
            tonalidadOriginal: tonalidadOriginal,
            tonalidadDestino: tonalidadActual,
          );

          final contenidoVisible = _mostrarAcordes
              ? contenidoTranspuesto
              : _ocultarAcordes(contenidoTranspuesto);

          final esFavorito =
              favoritos.contains(canto.id);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                40,
              ),
              children: [
                _Encabezado(
                  canto: canto,
                  uid: uid,
                  esFavorito: esFavorito,
                  onFavorito: uid == null
                      ? null
                      : () {
                          ref
                              .read(
                                favoritoControllerProvider
                                    .notifier,
                              )
                              .toggle(
                                uid: uid,
                                cantoId: canto.id,
                                marcarComoFavorito:
                                    !esFavorito,
                              );
                        },
                ),

                const SizedBox(height: 20),

                _Categorias(canto: canto),

                const SizedBox(height: 26),

                _SelectorTonalidad(
                  tonalidadOriginal: tonalidadOriginal,
                  tonalidadSeleccionada:
                      tonalidadActual,
                  mostrarAcordes: _mostrarAcordes,
                  onTonalidadChanged: (tonalidad) {
                    setState(() {
                      _tonalidadSeleccionada =
                          tonalidad;
                    });
                  },
                  onMostrarAcordesChanged: (valor) {
                    setState(() {
                      _mostrarAcordes = valor;
                    });
                  },
                ),

                const SizedBox(height: 24),

                _Recursos(canto: canto),

                const SizedBox(height: 28),

                Row(
                  children: [
                    const Icon(Icons.music_note),
                    const SizedBox(width: 8),
                    Text(
                      _mostrarAcordes
                          ? 'Letra y acordes'
                          : 'Letra',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _VisorCanto(
                  contenido: contenidoVisible,
                ),

                if (_tieneTexto(canto.licencia) ||
                    _tieneTexto(canto.fuenteUrl)) ...[
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InformacionFuente(canto: canto),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Canto? _buscarCanto(List<Canto> cantos) {
    for (final canto in cantos) {
      if (canto.id == widget.cantoId) {
        return canto;
      }
    }

    return null;
  }

  String _obtenerTonalidadOriginal(Canto canto) {
    final guardada = canto.tonalidadOriginal?.trim();

    if (guardada != null && guardada.isNotEmpty) {
      final normalizada =
          TranspositorAcordes.normalizarTonalidad(
        guardada,
      );

      if (TranspositorAcordes.tonalidadesDisponibles
          .contains(normalizada)) {
        return normalizada;
      }
    }

    return TranspositorAcordes.detectarTonalidad(
          canto.letra,
        ) ??
        'DO';
  }

  String _ocultarAcordes(String contenido) {
    return contenido
        .split('\n')
        .where((linea) {
          final texto = linea.trim();

          if (texto.isEmpty) {
            return true;
          }

          final elementos = RegExp(r'\S+')
              .allMatches(texto)
              .map((match) => match.group(0))
              .whereType<String>()
              .toList();

          if (elementos.isEmpty) {
            return true;
          }

          final sonAcordes = elementos.every(
            (elemento) => RegExp(
              r'^(DO|RE|MI|FA|SOL|LA|SI)'
              r'[#b]?'
              r'(m|maj|min|dim|aug|sus|add)?'
              r'[0-9]*(?:[/()+\-°#bA-Z0-9]*)?$',
              caseSensitive: false,
            ).hasMatch(elemento),
          );

          return !sonAcordes;
        })
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }
}

class _SelectorTonalidad extends StatelessWidget {
  final String tonalidadOriginal;
  final String tonalidadSeleccionada;
  final bool mostrarAcordes;
  final ValueChanged<String> onTonalidadChanged;
  final ValueChanged<bool> onMostrarAcordesChanged;

  const _SelectorTonalidad({
    required this.tonalidadOriginal,
    required this.tonalidadSeleccionada,
    required this.mostrarAcordes,
    required this.onTonalidadChanged,
    required this.onMostrarAcordesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tonalidad',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Original: $tonalidadOriginal',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: tonalidadSeleccionada,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Mostrar canción en',
              prefixIcon: Icon(Icons.music_note),
              border: OutlineInputBorder(),
            ),
            items: TranspositorAcordes
                .tonalidadesDisponibles
                .map(
                  (tonalidad) =>
                      DropdownMenuItem<String>(
                    value: tonalidad,
                    child: Text(
                      tonalidad == tonalidadOriginal
                          ? '$tonalidad (original)'
                          : tonalidad,
                    ),
                  ),
                )
                .toList(),
            onChanged: (valor) {
              if (valor != null) {
                onTonalidadChanged(valor);
              }
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: mostrarAcordes,
            contentPadding: EdgeInsets.zero,
            title: const Text('Mostrar acordes'),
            subtitle: Text(
              mostrarAcordes
                  ? 'Se muestra la letra con acordes.'
                  : 'Se muestra solamente la letra.',
            ),
            onChanged: onMostrarAcordesChanged,
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final Canto canto;
  final String? uid;
  final bool esFavorito;
  final VoidCallback? onFavorito;

  const _Encabezado({
    required this.canto,
    required this.uid,
    required this.esFavorito,
    required this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canto.titulo,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
              ),
              if (_tieneTexto(canto.autor)) ...[
                const SizedBox(height: 8),
                Text(
                  canto.autor!,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (uid != null) ...[
          const SizedBox(width: 12),
          FavoritoButton(
            esFavorito: esFavorito,
            onTap: onFavorito ?? () {},
          ),
        ],
      ],
    );
  }

  bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }
}

class _Categorias extends StatelessWidget {
  final Canto canto;

  const _Categorias({
    required this.canto,
  });

  @override
  Widget build(BuildContext context) {
    final tiempos = canto.tiemposLiturgicos
        .where((id) => id != 'todos');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tiempo in tiempos)
              Chip(
                avatar: const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                ),
                label: Text(
                  CantosConstants.etiquetaTiempo(
                    tiempo,
                  ),
                ),
              ),
            for (final momento in canto.momentosMisa)
              Chip(
                avatar: const Icon(
                  Icons.church_outlined,
                  size: 18,
                ),
                label: Text(
                  CantosConstants.etiquetaMomento(
                    momento,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Recursos extends StatelessWidget {
  final Canto canto;

  const _Recursos({
    required this.canto,
  });

  @override
  Widget build(BuildContext context) {
    final tieneAudio = _tieneTexto(canto.audioUrl);
    final tienePdf = _tieneTexto(canto.pdfUrl);

    if (!tieneAudio && !tienePdf) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (tieneAudio)
          FilledButton.tonalIcon(
            onPressed: () {
              _abrirEnlace(
                context,
                canto.audioUrl!,
              );
            },
            icon: const Icon(
              Icons.play_circle_outline,
            ),
            label: const Text('Escuchar audio'),
          ),
        if (tienePdf)
          PdfDownloadButton(
            pdfUrl: canto.pdfUrl!,
          ),
      ],
    );
  }

  bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }
}

class _VisorCanto extends StatelessWidget {
  final String contenido;

  const _VisorCanto({
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tamano = _calcularFuente(
            contenido,
            constraints.maxWidth,
          );

          return SelectableText(
            contenido.trim(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: tamano,
              height: 1.42,
            ),
          );
        },
      ),
    );
  }

  double _calcularFuente(
    String texto,
    double anchoDisponible,
  ) {
    const maximo = 15.0;
    const minimo = 8.5;

    final lineas = texto.split('\n');
    var lineaMasLarga = '';

    for (final linea in lineas) {
      if (linea.length > lineaMasLarga.length) {
        lineaMasLarga = linea;
      }
    }

    final medidor = TextPainter(
      text: TextSpan(
        text: lineaMasLarga,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: maximo,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    if (medidor.width <= anchoDisponible) {
      return maximo;
    }

    return (maximo *
            anchoDisponible /
            medidor.width)
        .clamp(minimo, maximo)
        .toDouble();
  }
}

class _InformacionFuente extends StatelessWidget {
  final Canto canto;

  const _InformacionFuente({
    required this.canto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de la fuente',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (_tieneTexto(canto.licencia)) ...[
          const SizedBox(height: 10),
          Text(canto.licencia!),
        ],
        if (_tieneTexto(canto.fuenteUrl)) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              _abrirEnlace(
                context,
                canto.fuenteUrl!,
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text(
              'Consultar fuente original',
            ),
          ),
        ],
      ],
    );
  }

  bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }
}

class _VistaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _VistaError({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            const Text(
              'No fue posible cargar el canto.',
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
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _abrirEnlace(
  BuildContext context,
  String enlace,
) async {
  final uri = Uri.tryParse(enlace.trim());

  if (uri == null) {
    return;
  }

  final abierto = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!abierto && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No fue posible abrir el enlace.',
        ),
      ),
    );
  }
}