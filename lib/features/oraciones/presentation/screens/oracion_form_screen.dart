// lib/features/oraciones/presentation/screens/oracion_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/oraciones_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/oracion.dart';
import '../providers/oraciones_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class OracionFormScreen extends ConsumerStatefulWidget {
  /// null → creando una oración nueva. No-null → editando esa oración.
  final String? oracionId;

  const OracionFormScreen({super.key, this.oracionId});

  @override
  ConsumerState<OracionFormScreen> createState() => _OracionFormScreenState();
}

class _OracionFormScreenState extends ConsumerState<OracionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _textoCtrl = TextEditingController();
  final _ordenCtrl = TextEditingController(text: '0');

  String _categoriaSeleccionada = OracionesConstants.categorias.first.id;
  bool _yaCargoDatosExistentes = false;

  bool get _esEdicion => widget.oracionId != null;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _textoCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  void _cargarDatosSiCorresponde(List<Oracion> oraciones) {
    if (_yaCargoDatosExistentes || !_esEdicion) return;
    Oracion? oracion;
    for (final o in oraciones) {
      if (o.id == widget.oracionId) {
        oracion = o;
        break;
      }
    }
    if (oracion == null) return;

    _tituloCtrl.text = oracion.titulo;
    _textoCtrl.text = oracion.texto;
    _ordenCtrl.text = oracion.orden.toString();
    _categoriaSeleccionada = oracion.categoria;
    _yaCargoDatosExistentes = true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final oracion = Oracion(
      id: widget.oracionId ?? '',
      titulo: _tituloCtrl.text.trim(),
      categoria: _categoriaSeleccionada,
      texto: _textoCtrl.text.trim(),
      orden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
      creadoPor: uid,
    );

    final ok = await ref.read(oracionesAdminControllerProvider.notifier).guardar(oracion);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oración guardada correctamente.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final oracionesAsync = ref.watch(oracionesStreamProvider);
    final state = ref.watch(oracionesAdminControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(oracionesAdminControllerProvider, (previous, next) {
      next.whenOrNull(error: (error, _) => _showError(error.toString()));
    });

    if (_esEdicion) {
      oracionesAsync.whenData(_cargarDatosSiCorresponde);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Oración' : 'Nueva Oración')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CustomTextField(
                controller: _tituloCtrl,
                label: 'Título',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: OracionesConstants.categorias
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.etiqueta)))
                    .toList(),
                onChanged: (v) => setState(() => _categoriaSeleccionada = v!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _textoCtrl,
                label: 'Texto completo',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ordenCtrl,
                label: 'Orden (número, menor aparece primero)',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || int.tryParse(v.trim()) == null) ? 'Ingresa un número' : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Guardar oración',
                isLoading: isLoading,
                onPressed: _guardar,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
