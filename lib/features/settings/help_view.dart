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

Widget _getCategoryIcon(String category) {
  switch (category) {
    case 'Arbitraje':
      return const Icon(Icons.gavel_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Comportamiento de jugadores':
      return const Icon(Icons.people_alt_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Comportamiento de público':
      return const Icon(Icons.volume_up_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Instalaciones inadecuadas':
      return const Icon(Icons.location_city_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Equipamiento defectuoso':
      return const Icon(Icons.sports_soccer_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Incidente de seguridad':
      return const Icon(Icons.security_rounded, color: Color(0xFF0CC0DF), size: 20);
    case 'Otro tipo de problema':
      return const Icon(Icons.error_outline_rounded, color: Color(0xFF0CC0DF), size: 20);
    default:
      return const Icon(Icons.category_rounded, color: Color(0xFF0CC0DF), size: 20);
  }
}

class _HelpFormViewState extends State<HelpFormView> {
  final user = FirebaseAuth.instance.currentUser;
  String? _selectedProblemCategory;
  int _selectedRating = 0;
  String? _imagePath;
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
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Reportar Problema',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0CC0DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(4),
        thickness: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reportar un Problema',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0CC0DF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ayúdanos a mejorar tu experiencia reportando cualquier problema que hayas encontrado.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Problem Category
              _buildSectionTitle('Categoría del Problema'),
              const SizedBox(height: 8),
              // Reemplaza el widget actual del dropdown por este código:
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedProblemCategory,
                    hint: const Text(
                      'Selecciona una categoría',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF0CC0DF),
                      size: 24,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    items: _problemCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              _getCategoryIcon(category),
                              const SizedBox(width: 12),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProblemCategory = value;
                      });
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return _problemCategories.map((String category) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _selectedProblemCategory ?? '',
                            style: const TextStyle(
                              color: Color(0xFF0CC0DF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),

// Añade este método auxiliar para los íconos de categoría

              const SizedBox(height: 24),

              // Rating Section
              _buildSectionTitle('Valoración General'),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: index < _selectedRating
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Image Upload
              _buildSectionTitle('Subir Evidencia Fotográfica (Opcional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _imagePath == null ? const Color(0xFFE2E8F0) : const Color(0xFF0EA5E9),
                      width: _imagePath == null ? 1 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, 
                                color: const Color(0xFF64748B), size: 36),
                            const SizedBox(height: 12),
                            Text(
                              'Toca para subir foto',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Formatos: JPG, PNG (hasta 10MB)',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_imagePath!), 
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Description Section
              _buildSectionTitle('Descripción Detallada'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Describe el problema en detalle...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons Section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async { 
                        if (_selectedProblemCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor selecciona una categoría'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                          return;
                        }

                        if (_descriptionController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingresa una descripción'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                              ),
                            ),
                          ),
                        );

                        try {
                          final report = ReportService();
                          await report.addReport( 
                            user?.uid ?? '',
                            _selectedProblemCategory ?? '',
                            _selectedRating,
                            _imagePath ?? '',
                            _descriptionController.text,
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Reporte enviado con éxito'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CC0DF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0CC0DF),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}