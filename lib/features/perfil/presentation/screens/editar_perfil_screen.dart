// lib/features/perfil/presentation/screens/editar_perfil_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/perfil_providers.dart';
import '../../../../shared/widgets/avatar_picker.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  File? _avatarLocal;
  bool _subiendoAvatar = false;

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(authStateProvider).value;
    _nombreCtrl = TextEditingController(text: usuario?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _onAvatarSelected(File file, String uid) async {
    setState(() {
      _avatarLocal = file;
      _subiendoAvatar = true;
    });
    final ok =
        await ref.read(perfilControllerProvider.notifier).updateAvatar(uid, file);
    if (!mounted) return;
    setState(() => _subiendoAvatar = false);
    if (!ok) {
      final error = ref.read(perfilControllerProvider);
      error.whenOrNull(error: (e, _) => _showError(e.toString()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authStateProvider).value;
    final state = ref.watch(perfilControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(perfilControllerProvider, (previous, next) {
      next.whenOrNull(error: (error, _) => _showError(error.toString()));
    });

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: AvatarPicker(
                    currentUrl: usuario.fotoUrl,
                    localPreview: _avatarLocal,
                    isLoading: _subiendoAvatar,
                    onImageSelected: (file) =>
                        _onAvatarSelected(file, usuario.uid),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nombreCtrl,
                  label: 'Nombre completo',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Guardar cambios',
                  isLoading: isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final ok = await ref
                          .read(perfilControllerProvider.notifier)
                          .updateProfile(_nombreCtrl.text.trim());
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perfil actualizado.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
