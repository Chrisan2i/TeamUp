import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/services/game_service.dart'; // <-- 1. IMPORTA EL SERVICIO

import '../../models/game_model.dart';
import '../../models/field_model.dart';

import 'widgets/step_zona.dart';
import 'widgets/step_fecha.dart';
import 'widgets/step_cancha.dart';
import 'widgets/step_detalles.dart';

class AddGameView extends StatefulWidget {
  const AddGameView({super.key});

  @override
  State<AddGameView> createState() => _AddGameViewState();
}

class _AddGameViewState extends State<AddGameView> {
  // --- 2. INSTANCIA EL SERVICIO ---
  final GameService _gameService = GameService();

  int _currentStep = 0;
  bool isPublishing = false;

  // ... (tus otras variables de estado no cambian)
  String? selectedZone;
  DateTime? selectedDate;
  FieldModel? selectedField;
  String? selectedHour;
  String? description;
  int? numberOfPlayers;
  bool isPublic = true;
  String? privateCode;

  String selectedSkillLevel = 'Beginner';
  double selectedDuration = 1.0;
  String selectedType = 'Amistoso';
  String selectedFormat = '7v7';
  int? minPlayersToConfirm;


  void nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void publishGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedField == null || !_canPublish()) {
      // Si no se puede publicar, no hacer nada.
      return;
    }

    setState(() => isPublishing = true);

    try {
      // Llama al método del servicio que crea el juego Y el chat
      final gameId = await _gameService.createGameAndChat(
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
      );

      if (gameId != null) {
        await _updateFieldAvailability();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Partido y chat creados con éxito')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Hubo un error al crear el partido.')),
          );
        }
      }
    } catch (e) {
      print('❌ Error al publicar el partido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error inesperado. Inténtalo de nuevo.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isPublishing = false);
      }
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
      appBar: AppBar(
        title: const Text('Crear Partido'),
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: previousStep,
        )
            : null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (_) {
                switch (_currentStep) {
                  case 0:
                    return StepZona(
                      selectedZone: selectedZone,
                      onSelect: (zona) {
                        setState(() {
                          selectedZone = zona;
                          nextStep();
                        });
                      },
                      onNext: nextStep,
                    );
                  case 1:
                    return StepFecha(
                      selectedDate: selectedDate,
                      onSelect: (date) {
                        setState(() {
                          selectedDate = date;
                          nextStep();
                        });
                      },
                    );
                  case 2:
                    if (selectedZone == null || selectedDate == null) {
                      return const Center(child: Text('⚠️ Zona o fecha no seleccionada'));
                    }
                    return StepCancha(
                      selectedZone: selectedZone!,
                      selectedDate: selectedDate!,
                      selectedField: selectedField?.name,
                      selectedHour: selectedHour,
                      onSelect: (fieldName, hour, fieldObject) {
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
          if (isPublishing)
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
        selectedHour != null;
  }

  String getFullEnglishWeekday(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }
}