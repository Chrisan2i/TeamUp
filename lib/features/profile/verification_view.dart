import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  // Estados para almacenar los TRES archivos de imagen
  File? _idCardFrontImage;
  File? _idCardBackImage;
  File? _faceWithIdImage;

  bool _isLoading = false;

  // --- FUNCIÓN REUTILIZABLE PARA SUBIR IMÁGENES A CLOUDINARY ---
  // He adaptado tu código de la captura de pantalla a una función auxiliar.
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/drnkgp6xe/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'TeamUp' // Tu preset de Cloudinary
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final imageUrl = json.decode(responseData)['secure_url'];
        print('Imagen subida con éxito: $imageUrl');
        return imageUrl;
      } else {
        print('Error al subir imagen a Cloudinary. Código: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }

  // --- LÓGICA PARA SELECCIONAR IMÁGENES (FUNCIONAL) ---
  Future<void> _pickImage(Function(File) onImageSelected, {bool useCamera = false}) async {
    final picker = ImagePicker();
    final source = useCamera ? ImageSource.camera : ImageSource.gallery;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 80); // Calidad para reducir tamaño

    if (pickedFile != null) {
      setState(() {
        onImageSelected(File(pickedFile.path));
      });
    }
  }

  // --- LÓGICA PARA ENVIAR LA VERIFICACIÓN (FUNCIONAL) ---
  void _submitVerification() async {
    if (_idCardFrontImage == null || _idCardBackImage == null || _faceWithIdImage == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Subir las TRES imágenes a Cloudinary en paralelo para más eficiencia
      final uploads = await Future.wait([
        _uploadImageToCloudinary(_idCardFrontImage!),
        _uploadImageToCloudinary(_idCardBackImage!),
        _uploadImageToCloudinary(_faceWithIdImage!),
      ]);

      final idCardFrontUrl = uploads[0];
      final idCardBackUrl = uploads[1];
      final faceWithIdUrl = uploads[2];

      // Si alguna de las subidas falla, detenemos el proceso
      if (idCardFrontUrl == null || idCardBackUrl == null || faceWithIdUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir una de las imágenes. Inténtalo de nuevo.'), backgroundColor: Colors.red),
          );
        }
        return; // Salimos de la función
      }

      // 2. Actualizar Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final verificationData = {
        'idCardFrontUrl': idCardFrontUrl,
        'idCardBackUrl': idCardBackUrl,
        'faceWithIdUrl': faceWithIdUrl,
        'status': 'pending', // El estado ahora sí es realmente "pendiente"
        'rejectionReason': null,
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'verification': verificationData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Verificación enviada! La revisaremos pronto.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error inesperado: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _idCardFrontImage != null && _idCardBackImage != null && _faceWithIdImage != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Verificación de Cuenta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Sección de Introducción ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0CC0DF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF0CC0DF), size: 40),
                  SizedBox(height: 12),
                  Text('Verifica tu Identidad en 3 Pasos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)), textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text('Este proceso nos ayuda a mantener la comunidad segura para todos.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Paso 1: Cédula Frontal ---
            _buildImagePickerBox(
              title: 'Paso 1: Documento (Frontal)',
              subtitle: 'Sube una foto clara de la parte frontal de tu documento.',
              icon: Icons.credit_card_outlined,
              onTap: () => _pickImage((file) => _idCardFrontImage = file),
              imageFile: _idCardFrontImage,
            ),
            const SizedBox(height: 24),

            // --- Paso 2: Cédula Trasera ---
            _buildImagePickerBox(
              title: 'Paso 2: Documento (Trasera)',
              subtitle: 'Sube una foto de la parte posterior de tu documento.',
              icon: Icons.credit_card_outlined,
              onTap: () => _pickImage((file) => _idCardBackImage = file),
              imageFile: _idCardBackImage,
            ),
            const SizedBox(height: 24),

            // --- Paso 3: Selfie con Cédula ---
            _buildImagePickerBox(
              title: 'Paso 3: Selfie con tu Documento',
              subtitle: 'Tómate una foto clara de tu rostro sosteniendo el documento.',
              icon: Icons.camera_alt_outlined,
              onTap: () => _pickImage((file) => _faceWithIdImage = file, useCamera: true),
              imageFile: _faceWithIdImage,
            ),
            const SizedBox(height: 40),

            // --- Botón de Envío ---
            ElevatedButton(
              onPressed: canSubmit && !_isLoading ? _submitVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0CC0DF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                shadowColor: const Color(0xFF0CC0DF).withOpacity(0.4),
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Enviar Verificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los selectores de imágenes
  Widget _buildImagePickerBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required File? imageFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
                  const SizedBox(height: 8),
                  Text(
                    'Tocar para ${icon == Icons.camera_alt_outlined ? "tomar foto" : "subir imagen"}',
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}