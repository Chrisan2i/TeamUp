import 'package:flutter/material.dart';

class RegistrationProvider with ChangeNotifier {
  // Datos del formulario
  String firstName = '';
  String lastName = '';
  String email = '';
  DateTime? birthDate;
  String? gender;
  String? skillLevel;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateData({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? skillLevel,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.email = email ?? this.email;
    this.birthDate = birthDate ?? this.birthDate;
    this.gender = gender ?? this.gender;
    this.skillLevel = skillLevel ?? this.skillLevel;
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}