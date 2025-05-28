import 'package:flutter/material.dart';
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
  int _currentStep = 0;

  String? selectedZone;
  DateTime? selectedDate;
  String? selectedField;
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

  void publishGame() {
    print("Publicando partido con:");
    print("Zona: $selectedZone");
    print("Fecha: $selectedDate");
    print("Cancha: $selectedField");
    print("Hora: $selectedHour");
    print("Jugadores: $numberOfPlayers");
    print("Público: $isPublic");
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
                return buildZonaStep(context, selectedZone, (zona) {
                  setState(() {
                    selectedZone = zona;
                    nextStep();
                  });
                });
              case 1:
                return buildFechaStep(context, selectedDate, (date) {
                  setState(() {
                    selectedDate = date;
                    nextStep();
                  });
                });
              case 2:
                return StepCancha(
                  selectedField: selectedField,
                  selectedHour: selectedHour,
                  onSelect: (field, hour) {
                    setState(() {
                      selectedField = field;
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
                  onHourSelected: (value) => setState(() => selectedHour = value),
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
