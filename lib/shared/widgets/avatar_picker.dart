// lib/shared/widgets/avatar_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentUrl;
  final File? localPreview;
  final bool isLoading;
  final ValueChanged<File> onImageSelected;

  const AvatarPicker({
    super.key,
    this.currentUrl,
    this.localPreview,
    this.isLoading = false,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) onImageSelected(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (localPreview != null) {
      backgroundImage = FileImage(localPreview!);
    } else if (currentUrl != null) {
      backgroundImage = NetworkImage(currentUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundImage: backgroundImage,
          child: backgroundImage == null
              ? const Icon(Icons.person, size: 44, color: AppColors.primary)
              : null,
        ),
        if (isLoading)
          const Positioned.fill(
            child: CircleAvatar(
              backgroundColor: Colors.black38,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isLoading ? null : () => _pickImage(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
