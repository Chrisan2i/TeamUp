import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/services/game_service.dart';

import 'package:teamup/core/constant/colors.dart';

import '../../models/game_model.dart';
import '../../models/field_model.dart';
import 'widgets/step_zona.dart';
import 'widgets/step_fecha.dart';
import 'widgets/step_cancha.dart';
import 'widgets/step_detalles.dart';

String getFullEnglishWeekday(DateTime date) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[date.weekday - 1];
}

class AddGameView extends StatefulWidget {
  const AddGameView({super.key});

  @override
  State<AddGameView> createState() => _AddGameViewState();
}

class _AddGameViewState extends State<AddGameView> {
  final GameService _gameService = GameService();
  int _currentStep = 0;
  bool _isPublishing = false;
  bool _isFetchingAvailability = false; // 💡 Nuevo estado para la carga de disponibilidad

  // Estado del formulario
  String? selectedZone;
  DateTime? selectedDate;
  FieldModel? selectedField;
  String? selectedHour;
  String? description;
  int? numberOfPlayers;
  bool isPublic = true;
  String? privateCode;
  String selectedSkillLevel = 'Beginner';
  String selectedType = 'Amistoso';
  int? minPlayersToConfirm;


  Map<String, bool> _availabilityByWeekday = {};

  void nextStep() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  /// 💡 NUEVO MÉTODO: Obtiene la disponibilidad de canchas para una zona específica.
  Future<void> _fetchAvailabilityForZone(String zoneName) async {
    setState(() => _isFetchingAvailability = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('fields')
        .where('zone', isEqualTo: zoneName)
        .where('isActive', isEqualTo: true)
        .get();

    final Map<String, bool> availabilityMap = {};
    for (var doc in snapshot.docs) {
      final field = FieldModel.fromMap(doc.data(), doc.id);
      field.availability.forEach((weekday, hours) {
        if (hours.isNotEmpty) {
          availabilityMap[weekday] = true;
        }
      });
    }

    setState(() {
      _availabilityByWeekday = availabilityMap;
      _isFetchingAvailability = false;
    });
  }

  // ... (el método publishGame no necesita grandes cambios, pero lo incluyo por completitud)
  void publishGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedField == null || !_canPublish()) return;
    setState(() => _isPublishing = true);
    try {
      await _gameService.createGameAndChat(
        zone: selectedZone!,
        fieldName: selectedField!.name,
        date: selectedDate!,
        hour: selectedHour!,
        description: description ?? '',
        playerCount: numberOfPlayers ?? 0,
        isPublic: isPublic,
        price: selectedField!.getPricePerPersonAuto(),
        duration: selectedField!.duration,
        imageUrl: selectedField!.imageUrl,
        skillLevel: selectedSkillLevel,
        type: selectedType,
        format: selectedField!.format,
        footwear: selectedField!.footwear,
        minPlayersToConfirm: minPlayersToConfirm ?? selectedField!.minPlayersToBook,
        privateCode: isPublic ? null : privateCode,
        location: selectedField!.location,
      );

      await _updateFieldAvailability();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Partido y chat creados con éxito')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error al publicar el partido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error inesperado. Inténtalo de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _updateFieldAvailability() async {
    final weekdayKey = getFullEnglishWeekday(selectedDate!);
    final fieldRef = FirebaseFirestore.instance.collection('fields').doc(selectedField!.id);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(fieldRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final availability = Map<String, dynamic>.from(data['availability'] ?? {});
      final List<String> hours = List<String>.from(availability[weekdayKey] ?? []);
      if (hours.any((h) => h.trim() == selectedHour!.trim())) {
        hours.removeWhere((h) => h.trim() == selectedHour!.trim());
        availability[weekdayKey] = hours;
        transaction.update(fieldRef, {'availability': availability});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Crear Partido - Paso ${_currentStep + 1} de 4'),
        backgroundColor: const Color(0xFFF8FAFC),
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: previousStep)
            : null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Builder(
              builder: (_) {
                if (_isFetchingAvailability) {
                  return const Center(child: CircularProgressIndicator());
                }
                switch (_currentStep) {
                  case 0:
                    return StepZona(
                      selectedZone: selectedZone,
                      onSelect: (zona) async {
                        setState(() {
                          selectedZone = zona;
                          selectedDate = null;
                          selectedField = null;
                          selectedHour = null;
                        });
                        await _fetchAvailabilityForZone(zona);
                        nextStep();
                      },
                    );
                  case 1:
                    return StepFecha(
                      selectedDate: selectedDate,
                      availableWeekdays: _availabilityByWeekday,
                      onSelect: (date) {
                        setState(() => selectedDate = date);
                        nextStep();
                      },
                    );
                  case 2:
                    if (selectedZone == null || selectedDate == null) {
                      return const Center(child: Text('⚠️ Zona o fecha no seleccionada'));
                    }
                    return StepCancha(
                      selectedZone: selectedZone!,
                      selectedDate: selectedDate!,
                      selectedField: selectedField?.id,
                      selectedHour: selectedHour,
                      onSelect: (hour, fieldObject) {
                        setState(() {
                          selectedField = fieldObject;
                          selectedHour = hour;
                        });
                      },
                      onNext: nextStep,
                    );
                  case 3:
                    return StepDetalles(
                      selectedZone: selectedZone,
                      selectedField: selectedField,
                      selectedDate: selectedDate,
                      selectedHour: selectedHour,
                      description: description,
                      numberOfPlayers: numberOfPlayers,
                      isPublic: isPublic,
                      privateCode: privateCode,
                      selectedSkillLevel: selectedSkillLevel,
                      selectedDuration: selectedField?.duration ?? 1.0,
                      selectedType: selectedType,
                      selectedFormat: selectedField?.format ?? '7v7',
                      selectedFootwear: selectedField?.footwear ?? 'any',
                      minPlayersToConfirm: minPlayersToConfirm,
                      onDescriptionChanged: (value) => setState(() => description = value),
                      onPlayersChanged: (value) => setState(() => numberOfPlayers = int.tryParse(value)),
                      onMinPlayersChanged: (value) => setState(() => minPlayersToConfirm = int.tryParse(value)),
                      onPublicChanged: (value) => setState(() {
                        isPublic = value;
                        if (value) privateCode = null;
                      }),
                      onPrivateCodeChanged: (value) => setState(() => privateCode = value),
                      onSkillLevelChanged: (value) => setState(() => selectedSkillLevel = value),
                      onTypeChanged: (value) => setState(() => selectedType = value),
                      onPublish: publishGame,
                      canPublish: _canPublish(),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          if (_isPublishing)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  bool _canPublish() {
    return selectedZone != null &&
        selectedDate != null &&
        selectedField != null &&
        selectedHour != null &&
        numberOfPlayers != null &&
        numberOfPlayers! > 0;
  }
}