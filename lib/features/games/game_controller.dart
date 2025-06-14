import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/game_model.dart';

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;


  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];

  DateTime? selectedDate;
  String searchText = '';

  /// Debería ser proporcionado por AuthService al iniciar sesión
  String currentUserId = '';

  GameController() {
    loadGames();
  }

  Future<void> loadGames() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('games').orderBy('date').get();
      debugPrint('🎮 Juegos encontrados: ${snapshot.docs.length}');

      allGames = snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint("📄 Game doc: $data");
        return GameModel.fromMap(data);
      }).toList();

      applyFilters();
    } catch (e) {
      debugPrint('❌ Error cargando juegos: $e');
    }

    isLoading = false;
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

  /// 🧠 Aplicar filtros activos: fecha y búsqueda
  void applyFilters() {
    final now = DateTime.now();

    filteredGames = allGames.where((game) {
      // ✅ Mostrar solo juegos de hoy o futuros (ignorando la hora)
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
      final today = DateTime(now.year, now.month, now.day);

      if (gameDay.isBefore(today)) return false;

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
        final matchesDescription = game.description.toLowerCase().contains(search);
        final matchesZone = game.zone.toLowerCase().contains(search);

        if (!matchesField && !matchesDescription && !matchesZone) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

}
