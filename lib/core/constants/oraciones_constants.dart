// lib/core/constants/oraciones_constants.dart

class CategoriaOracionOpcion {
  final String id;
  final String etiqueta;
  const CategoriaOracionOpcion(this.id, this.etiqueta);
}

class OracionesConstants {
  OracionesConstants._();

  static const List<CategoriaOracionOpcion> categorias = [
    CategoriaOracionOpcion('manana', 'Oraciones de la mañana'),
    CategoriaOracionOpcion('noche', 'Oraciones de la noche'),
    CategoriaOracionOpcion('novenas', 'Novenas'),
    CategoriaOracionOpcion('tradicionales', 'Tradicionales'),
    CategoriaOracionOpcion('especiales', 'Para ocasiones especiales'),
  ];

  static String etiquetaCategoria(String id) {
    return categorias
        .firstWhere((c) => c.id == id, orElse: () => CategoriaOracionOpcion(id, id))
        .etiqueta;
  }
}
