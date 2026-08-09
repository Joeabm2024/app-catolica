import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/cantos_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/canto.dart';
import '../providers/cantos_providers.dart';
import '../widgets/canto_list_tile.dart';

enum TipoCategoriaCanto { momentoMisa, tiempoLiturgico }

class CategoriaCantoSeleccionada {
  final String id;
  final String titulo;
  final TipoCategoriaCanto tipo;

  const CategoriaCantoSeleccionada({
    required this.id,
    required this.titulo,
    required this.tipo,
  });
}

class CantosScreen extends ConsumerStatefulWidget {
  const CantosScreen({super.key});

  @override
  ConsumerState<CantosScreen> createState() {
    return _CantosScreenState();
  }
}

class _CantosScreenState extends ConsumerState<CantosScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  String _busqueda = '';
  CategoriaCantoSeleccionada? _categoriaSeleccionada;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cantosAsync = ref.watch(cantosStreamProvider);

    final favoritos =
        ref.watch(cantosFavoritosStreamProvider).value ?? <String>{};

    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: _categoriaSeleccionada == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Volver a categorías',
                onPressed: _volverACategorias,
              ),
        title: Text(_categoriaSeleccionada?.titulo ?? 'Cantos'),
        actions: [
          if (_categoriaSeleccionada != null)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Ver todas las categorías',
              onPressed: _volverACategorias,
            ),
        ],
      ),
      body: cantosAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
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
          final cantosOrdenados = List<Canto>.from(cantos)
            ..sort(_compararCantos);

          return Column(
            children: [
              _BarraBusqueda(
                controller: _busquedaController,
                onChanged: (texto) {
                  setState(() {
                    _busqueda = texto;
                  });
                },
                onLimpiar: _limpiarBusqueda,
              ),
              Expanded(
                child: _construirContenido(
                  cantos: cantosOrdenados,
                  favoritos: favoritos,
                  uid: uid,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirContenido({
    required List<Canto> cantos,
    required Set<String> favoritos,
    required String? uid,
  }) {
    if (_busqueda.trim().isNotEmpty) {
      final resultados = _buscarCantos(cantos, _busqueda);

      return _ListaResultados(
        titulo: 'Resultados de búsqueda',
        descripcion: '${resultados.length} canciones encontradas',
        cantos: resultados,
        favoritos: favoritos,
        uid: uid,
        onAbrirCanto: _abrirCanto,
      );
    }

    final categoria = _categoriaSeleccionada;

    if (categoria != null) {
      final cantosCategoria = _filtrarCategoria(cantos, categoria);

      return _ListaCategoria(
        categoria: categoria,
        cantos: cantosCategoria,
        favoritos: favoritos,
        uid: uid,
        onAbrirCanto: _abrirCanto,
        onVolver: _volverACategorias,
      );
    }

    return _MenuCategorias(
      cantos: cantos,
      onSeleccionar: _seleccionarCategoria,
    );
  }

  List<Canto> _buscarCantos(List<Canto> cantos, String busqueda) {
    final texto = _normalizarTexto(busqueda);

    return cantos.where((canto) {
      final titulo = _normalizarTexto(canto.titulo);
      final autor = _normalizarTexto(canto.autor ?? '');

      return titulo.contains(texto) || autor.contains(texto);
    }).toList();
  }

  List<Canto> _filtrarCategoria(
    List<Canto> cantos,
    CategoriaCantoSeleccionada categoria,
  ) {
    final resultados = cantos.where((canto) {
      switch (categoria.tipo) {
        case TipoCategoriaCanto.momentoMisa:
          return canto.momentosMisa.contains(categoria.id);

        case TipoCategoriaCanto.tiempoLiturgico:
          return canto.tiemposLiturgicos.contains(categoria.id);
      }
    }).toList();

    resultados.sort(_compararCantos);

    return resultados;
  }

  int _compararCantos(Canto primero, Canto segundo) {
    return _normalizarTexto(
      primero.titulo,
    ).compareTo(_normalizarTexto(segundo.titulo));
  }

  void _seleccionarCategoria(CategoriaCantoSeleccionada categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
  }

  void _volverACategorias() {
    setState(() {
      _categoriaSeleccionada = null;
    });
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();

    setState(() {
      _busqueda = '';
    });
  }

  void _abrirCanto(Canto canto) {
    context.push('/cantos/${canto.id}');
  }

  String _normalizarTexto(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}

class _BarraBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;

  const _BarraBusqueda({
    required this.controller,
    required this.onChanged,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por título o autor',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: onLimpiar,
                ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _MenuCategorias extends StatelessWidget {
  final List<Canto> cantos;
  final ValueChanged<CategoriaCantoSeleccionada> onSeleccionar;

  const _MenuCategorias({required this.cantos, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    final categoriasMisa = CantosConstants.momentosMisa.map((opcion) {
      return _CategoriaConCantidad(
        categoria: CategoriaCantoSeleccionada(
          id: opcion.id,
          titulo: opcion.etiqueta,
          tipo: TipoCategoriaCanto.momentoMisa,
        ),
        cantidad: cantos.where((canto) {
          return canto.momentosMisa.contains(opcion.id);
        }).length,
      );
    }).toList();

    final categoriasTiempo = CantosConstants.tiemposLiturgicos
        .where((opcion) => opcion.id != 'todos')
        .map((opcion) {
          return _CategoriaConCantidad(
            categoria: CategoriaCantoSeleccionada(
              id: opcion.id,
              titulo: opcion.etiqueta,
              tipo: TipoCategoriaCanto.tiempoLiturgico,
            ),
            cantidad: cantos.where((canto) {
              return canto.tiemposLiturgicos.contains(opcion.id);
            }).length,
          );
        })
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _EncabezadoCatalogo(cantidadCantos: cantos.length),
        const SizedBox(height: 24),
        _TituloSeccion(
          icono: Icons.church_outlined,
          titulo: 'Momentos de la misa',
          descripcion: 'Selecciona el momento litúrgico del canto.',
        ),
        const SizedBox(height: 14),
        _CuadriculaCategorias(
          categorias: categoriasMisa,
          onSeleccionar: onSeleccionar,
        ),
        const SizedBox(height: 30),
        _TituloSeccion(
          icono: Icons.calendar_month_outlined,
          titulo: 'Tiempo litúrgico',
          descripcion: 'Cantos recomendados para cada temporada.',
        ),
        const SizedBox(height: 14),
        _CuadriculaCategorias(
          categorias: categoriasTiempo,
          onSeleccionar: onSeleccionar,
        ),
      ],
    );
  }
}

class _EncabezadoCatalogo extends StatelessWidget {
  final int cantidadCantos;

  const _EncabezadoCatalogo({required this.cantidadCantos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_music_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancionero católico',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadCantos canciones disponibles',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _TituloSeccion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                descripcion,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CuadriculaCategorias extends StatelessWidget {
  final List<_CategoriaConCantidad> categorias;
  final ValueChanged<CategoriaCantoSeleccionada> onSeleccionar;

  const _CuadriculaCategorias({
    required this.categorias,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final columnas = ancho >= 700 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categorias.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: ancho >= 700 ? 2.5 : 1.55,
      ),
      itemBuilder: (context, index) {
        final elemento = categorias[index];

        return _TarjetaCategoria(
          elemento: elemento,
          onTap: () {
            onSeleccionar(elemento.categoria);
          },
        );
      },
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  final _CategoriaConCantidad elemento;
  final VoidCallback onTap;

  const _TarjetaCategoria({required this.elemento, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final deshabilitada = elemento.cantidad == 0;

    return Material(
      color: deshabilitada
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: deshabilitada ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _iconoCategoria(elemento.categoria.id),
                color: deshabilitada
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 7),
              Text(
                elemento.categoria.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: deshabilitada ? Theme.of(context).disabledColor : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${elemento.cantidad} '
                '${elemento.cantidad == 1 ? 'canto' : 'cantos'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: deshabilitada
                      ? Theme.of(context).disabledColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconoCategoria(String id) {
    switch (id) {
      case 'entrada':
        return Icons.login;
      case 'acto_penitencial':
        return Icons.favorite_border;
      case 'gloria':
        return Icons.wb_sunny_outlined;
      case 'salmo':
        return Icons.menu_book_outlined;
      case 'aclamacion':
        return Icons.celebration_outlined;
      case 'leccional':
        return Icons.auto_stories_outlined;
      case 'ofertorio':
        return Icons.volunteer_activism_outlined;
      case 'santo':
        return Icons.church_outlined;
      case 'padrenuestro':
        return Icons.people_outline;
      case 'paz':
        return Icons.handshake_outlined;
      case 'cordero':
        return Icons.cruelty_free_outlined;
      case 'comunion':
        return Icons.local_dining_outlined;
      case 'espiritu_santo':
        return Icons.air;
      case 'salida':
        return Icons.logout;
      case 'mariano':
        return Icons.local_florist_outlined;
      case 'rosario':
        return Icons.radio_button_checked;
      case 'matrimonio':
        return Icons.favorite;
      case 'villancico':
      case 'navidad':
        return Icons.star_outline;
      case 'adviento':
        return Icons.light_mode_outlined;
      case 'cuaresma':
        return Icons.self_improvement;
      case 'pascua':
        return Icons.emoji_nature_outlined;
      default:
        return Icons.music_note;
    }
  }
}

class _ListaCategoria extends StatelessWidget {
  final CategoriaCantoSeleccionada categoria;
  final List<Canto> cantos;
  final Set<String> favoritos;
  final String? uid;
  final ValueChanged<Canto> onAbrirCanto;
  final VoidCallback onVolver;

  const _ListaCategoria({
    required this.categoria,
    required this.cantos,
    required this.favoritos,
    required this.uid,
    required this.onAbrirCanto,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    if (cantos.isEmpty) {
      return _CategoriaVacia(categoria: categoria.titulo, onVolver: onVolver);
    }

    return _ListaResultados(
      titulo: categoria.titulo,
      descripcion:
          '${cantos.length} ${cantos.length == 1 ? 'canto' : 'cantos'}',
      cantos: cantos,
      favoritos: favoritos,
      uid: uid,
      onAbrirCanto: onAbrirCanto,
    );
  }
}

class _ListaResultados extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final List<Canto> cantos;
  final Set<String> favoritos;
  final String? uid;
  final ValueChanged<Canto> onAbrirCanto;

  const _ListaResultados({
    required this.titulo,
    required this.descripcion,
    required this.cantos,
    required this.favoritos,
    required this.uid,
    required this.onAbrirCanto,
  });

  @override
  Widget build(BuildContext context) {
    if (cantos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 58),
              SizedBox(height: 14),
              Text('No se encontraron canciones.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                descripcion,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: cantos.length,
            itemBuilder: (context, index) {
              final canto = cantos[index];

              return CantoListTile(
                canto: canto,
                esFavorito: favoritos.contains(canto.id),
                onTap: () {
                  onAbrirCanto(canto);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoriaVacia extends StatelessWidget {
  final String categoria;
  final VoidCallback onVolver;

  const _CategoriaVacia({required this.categoria, required this.onVolver});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_outlined, size: 60),
            const SizedBox(height: 16),
            Text(
              'Todavía no hay canciones publicadas '
              'en la categoría “$categoria”.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.tonalIcon(
              onPressed: onVolver,
              icon: const Icon(Icons.grid_view),
              label: const Text('Ver otras categorías'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VistaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _VistaError({required this.mensaje, required this.onReintentar});

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
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text('No fue posible cargar el catálogo.'),
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
    );
  }
}

class _CategoriaConCantidad {
  final CategoriaCantoSeleccionada categoria;
  final int cantidad;

  const _CategoriaConCantidad({
    required this.categoria,
    required this.cantidad,
  });
}
