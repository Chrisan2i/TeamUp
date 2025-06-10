import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/game_model.dart';

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];

  DateTime? selectedDate;
  String searchText = '';

  /// Debería ser proporcionado por AuthService al iniciar sesión
  String currentUserId = '';

  GameController() {
    loadGames();
  }

  /// 🔄 Cargar todos los partidos desde Firebase
  Future<void> loadGames() async {
    try {
      final snapshot = await _firestore.collection('games').orderBy('date').get();
      allGames = snapshot.docs.map((doc) => GameModel.fromMap(doc.data())).toList();
      applyFilters();
    } catch (e) {
      debugPrint('Error cargando juegos: $e');
    }
  }

  /// 📅 Cambiar fecha seleccionada
  void setDate(DateTime date) {
    selectedDate = date;
    applyFilters();
    notifyListeners();
  }

  /// 🔍 Cambiar texto de búsqueda
  void setSearchText(String text) {
    searchText = text;
    applyFilters();
    notifyListeners();
  }

  /// 🧠 Aplicar filtros activos: fecha y búsqueda
  void applyFilters() {
    filteredGames = allGames.where((game) {
      // ✅ Mostrar solo juegos futuros
      if (game.date.isBefore(DateTime.now())) return false;

      // 📅 Filtro por fecha exacta
      if (selectedDate != null) {
        final sameDay = game.date.year == selectedDate!.year &&
            game.date.month == selectedDate!.month &&
            game.date.day == selectedDate!.day;
        if (!sameDay) return false;
      }

      // 🔍 Filtro por texto múltiple
      if (searchText.isNotEmpty) {
        final search = searchText.toLowerCase();
        final matchesField = game.fieldName.toLowerCase().contains(search);
        final matchesDescription = game.description.toLowerCase().contains(search) ?? false;
        final matchesZone = game.zone.toLowerCase().contains(search) ?? false;

        if (!matchesField && !matchesDescription && !matchesZone) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
