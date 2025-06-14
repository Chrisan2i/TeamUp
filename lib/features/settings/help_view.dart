import 'package:flutter/material.dart';

class HelpFormView extends StatefulWidget {
  const HelpFormView({super.key});

  @override
  State<HelpFormView> createState() => _HelpFormViewState();
}

class _HelpFormViewState extends State<HelpFormView> {
  String? _selectedProblemCategory;
  int _selectedRating = 0;
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
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Reportar Problema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportar un Problema',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ayúdanos a mejorar tu experiencia reportando cualquier problema que hayas encontrado. Tu feedback es valioso para nosotros.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Categoría del problema
            const Text(
              'Categoría del Problema',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            // AQUÍ VA EL NUEVO CÓDIGO DEL MENÚ DESPLEGABLE:
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text(
                    'Selecciona una categoría',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  value: _selectedProblemCategory,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _problemCategories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProblemCategory = newValue;
                    });
                  },
                ),
              ),
            ),
            
            // Valoración de satisfacción
            const Text(
                  'Valoración General',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1; // +1 porque el índice empieza en 0
                        });
                      },
                      child: Icon(
                        Icons.star,
                        size: 32,
                        color: index < _selectedRating 
                            ? const Color(0xFF0CC0DF)  // Color cuando está seleccionada
                            : Colors.grey[300],        // Color cuando no está seleccionada
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por favor califica tu experiencia general',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
            
            // Subir foto (opcional)
            const Text(
              'Subir Evidencia Fotográfica (Opcional)',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload, size: 32, color: Color(0xFF6B7280)),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca para subir foto',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG hasta 10MB',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Descripción detallada
            const Text(
              'Descripción Detallada',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Describe el problema en detalle...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 32),
            
            // Botones
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Verifica que se haya seleccionado una categoría
                      if (_selectedProblemCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor selecciona una categoría'),
                          ),
                        );
                        return;
                      }

                      // Muestra el mensaje de confirmación
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
  }



}