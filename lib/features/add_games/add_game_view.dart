import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/game_model.dart';
import '../../models/field_model.dart'; // Asegúrate de importar esto

import 'widgets/step_zona.dart';
import 'widgets/step_fecha.dart';
import 'widgets/step_cancha.dart';
import 'widgets/step_detalles.dart';
import '../../services/game_service.dart';

class AddGameView extends StatefulWidget {
  const AddGameView({super.key});

  @override
  State<AddGameView> createState() => _AddGameViewState();
}

class _AddGameViewState extends State<AddGameView> {
  int _currentStep = 0;

  String? selectedZone;
  DateTime? selectedDate;
  FieldModel? selectedField;
  String? selectedHour;
  String? description;
  int? numberOfPlayers;
  bool isPublic = true;

  void nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void publishGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedField == null) return;

    final gameService = GameService();

    final newGame = GameModel(
      id: '',
      ownerId: user.uid,
      zone: selectedZone!,
      fieldName: selectedField!.name,
      date: selectedDate!,
      hour: selectedHour!,
      description: description ?? '',
      playerCount: numberOfPlayers ?? 0,
      isPublic: isPublic,
      price: selectedField!.pricePerHour,
      createdAt: DateTime.now().toIso8601String(),
      imageUrl: selectedField!.imageUrl,
      usersjoined: [],
    );

    final docRef = await FirebaseFirestore.instance.collection('games').add(newGame.toMap());

    // Actualizar ID del partido
    await gameService.updateGame(newGame.copyWith(id: docRef.id));

    // 🔴 ELIMINAR HORA RESERVADA DE LA CANCHA
    try {
      final weekdayKey = getFullEnglishWeekday(selectedDate!); // Ej: Monday
      final fieldRef = FirebaseFirestore.instance.collection('fields').doc(selectedField!.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(fieldRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final availability = Map<String, dynamic>.from(data['availability'] ?? {});
        final List<dynamic> hours = List<String>.from(availability[weekdayKey] ?? []);

        if (hours.contains(selectedHour)) {
          hours.remove(selectedHour);
          availability[weekdayKey] = hours;
          transaction.update(fieldRef, {'availability': availability});
          print('🕒 Hora eliminada correctamente de la disponibilidad');
        } else {
          print('⚠️ Hora no encontrada en la disponibilidad');
        }
      });
    } catch (e) {
      print('❌ Error al eliminar la hora de disponibilidad: $e');
    }

    // Feedback UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Partido creado con éxito')),
    );
    Navigator.pop(context);
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
      body: Padding(
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
                  selectedField: selectedField?.name,
                  selectedDate: selectedDate,
                  selectedHour: selectedHour,
                  description: description,
                  numberOfPlayers: numberOfPlayers,
                  isPublic: isPublic,
                  onDescriptionChanged: (value) => setState(() => description = value),
                  onPlayersChanged: (value) => setState(() => numberOfPlayers = int.tryParse(value)),
                  onPublicChanged: (value) => setState(() => isPublic = value),
                  onPublish: publishGame,
                  canPublish: _canPublish(),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  bool _canPublish() {
    return selectedZone != null &&
        selectedDate != null &&
        selectedField != null &&
        selectedHour != null;
  }
}
