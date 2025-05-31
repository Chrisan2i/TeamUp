import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/game_model.dart';

/// Tabs principales de la sección de juegos
enum GameTab { open, my, past }

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];

  GameTab currentTab = GameTab.open;
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

  /// 📤 Cambiar tab actual (Open / My / Past)
  void setTab(GameTab tab) {
    currentTab = tab;
    applyFilters();
    notifyListeners();
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

  /// 🧠 Aplicar filtros activos: tab, fecha y búsqueda
  void applyFilters() {
    filteredGames = allGames.where((game) {
      // Filtro por pestaña
      if (currentTab == GameTab.my && game.ownerId != currentUserId) return false;
      if (currentTab == GameTab.past && game.date.isAfter(DateTime.now())) return false;
      if (currentTab == GameTab.open && game.date.isBefore(DateTime.now())) return false;

      // Filtro por fecha exacta
      if (selectedDate != null) {
        final sameDay = game.date.year == selectedDate!.year &&
            game.date.month == selectedDate!.month &&
            game.date.day == selectedDate!.day;
        if (!sameDay) return false;
      }

      // Filtro por texto (por nombre del campo, si aplica)
      if (searchText.isNotEmpty &&
          !game.fieldName.toLowerCase().contains(searchText.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }
}
