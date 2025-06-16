import 'package:flutter/material.dart';
import 'package:teamup/services/report_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HelpFormView extends StatefulWidget {
  const HelpFormView({super.key});

  @override
  State<HelpFormView> createState() => _HelpFormViewState();
}



class _HelpFormViewState extends State<HelpFormView> {
  final user = FirebaseAuth.instance.currentUser;
  String? _selectedProblemCategory;
  int _selectedRating = 0;
   String? _imagePath;
  // Para la descripción
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _problemCategories = [
    'Arbitraje',
    'Comportamiento de jugadores',
    'Comportamiento de público',
    'Instalaciones inadecuadas',
    'Equipamiento defectuoso',
    'Incidente de seguridad',
    'Otro tipo de problema'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path; // Guardamos la ruta del archivo
      });
    }
  }

  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Reportar Problema',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(4),
        thickness: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reportar un Problema',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ayúdanos a mejorar tu experiencia reportando cualquier problema que hayas encontrado.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Categoría del Problema',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedProblemCategory,
                    hint: const Text(
                      'Selecciona una categoría',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _problemCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProblemCategory = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Valoración General',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 32,
                      color: index < _selectedRating
                          ? const Color(0xFF0CC0DF)
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              const Text(
                'Subir Evidencia Fotográfica (Opcional)',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload, color: Color(0xFF6B7280), size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Toca para subir foto',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG, PNG hasta 10MB',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Descripción Detallada',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Describe el problema en detalle...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  expands: true,
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedProblemCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor selecciona una categoría'),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Reporte enviado correctamente'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CC0DF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}