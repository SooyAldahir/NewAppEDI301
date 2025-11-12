// lib/src/pages/Family/family_controller.dart
import 'dart:io'; // <-- Importar para File
import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/familia_api.dart';
import 'package:edi301/auth/token_storage.dart'; // <-- Importar
import 'package:image_picker/image_picker.dart'; // <-- Importar

class FamilyController {
  final _api = FamiliaApi();
  final _tokenStorage = TokenStorage(); // <-- Añadir
  final _picker = ImagePicker(); // <-- Añadir

  final family = ValueNotifier<Family?>(null);
  final loading = ValueNotifier<bool>(true);
  final error = ValueNotifier<String?>(null);

  void dispose() {
    family.dispose();
    loading.dispose();
    error.dispose();
  }

  // Carga la familia del usuario
  Future<void> loadMyFamily(BuildContext context) async {
    loading.value = true;
    error.value = null;
    try {
      // Esta API devuelve una lista, asumimos que la familia
      // del usuario es la primera
      final fams = await _api.getMyFamily();
      if (fams.isEmpty) {
        throw Exception('No estás asignado a ninguna familia.');
      }

      // Cargar los detalles completos (getMyFamily no trae miembros)
      final fullFamilyData = await _api.getById(fams.first.id!);
      family.value = Family.fromJson(fullFamilyData!);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  // --- AÑADIR NUEVA LÓGICA DE SUBIDA ---

  /// Muestra un diálogo para elegir Cámara o Galería
  Future<ImageSource?> showImageSource(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Pide al usuario que elija una imagen
  Future<File?> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70, // Comprimir un poco la imagen
      maxWidth: 1024,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// 2. Sube la imagen elegida al backend
  Future<void> pickAndUploadImage(
    BuildContext context,
    ImageSource source, {
    bool isCover = false,
  }) async {
    final file = await _pickImage(source);
    if (file == null) return; // El usuario canceló

    loading.value = true; // Mostrar spinner
    try {
      final token = await _tokenStorage.read();
      if (token == null) throw Exception('Usuario no autenticado');
      if (family.value?.id == null)
        throw Exception('No se ha cargado la familia');

      final Family updatedFamily;

      if (isCover) {
        updatedFamily = await _api.uploadFamilyFotos(
          familiaId: family.value!.id!,
          token: token,
          fotoPortada: file,
        );
      } else {
        updatedFamily = await _api.uploadFamilyFotos(
          familiaId: family.value!.id!,
          token: token,
          fotoPerfil: file,
        );
      }

      // 3. Actualizar la UI con la nueva familia
      family.value = updatedFamily;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  // --- FIN DE LA NUEVA LÓGICA ---
}
