import 'dart:async';
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

  StreamSubscription? _gamesSubscription;

  GameController() {
    _listenToGames();
  }

  /// 🔄 Escucha en tiempo real los cambios en Firestore
  void _listenToGames() {
    isLoading = true;
    notifyListeners();

    _gamesSubscription = _firestore
        .collection('games')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      allGames = snapshot.docs.map((doc) {
        final data = doc.data();
        return GameModel.fromMap(data);
      }).toList();

      applyFilters();
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Error escuchando juegos: $e');
      isLoading = false;
      notifyListeners();
    });
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

  void applyFilters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    filteredGames = allGames.where((game) {
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);

      // ⛔ Ocultar partidos pasados
      if (gameDay.isBefore(today)) return false;

      // ⛔ Ocultar partidos privados
      if (!game.isPublic) return false;

      // ⛔ Ocultar si ya está unido (opcional)
      if (game.usersjoined.contains(currentUserId)) return false;

      // 📅 Filtro por fecha exacta
      if (selectedDate != null) {
        final selectedDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
        if (gameDay != selectedDay) return false;
      }

      // 🔍 Filtro por texto
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


  void setCurrentUser(String uid) {
    currentUserId = uid;
    applyFilters(); // Para que se actualice la lista al asignar el UID
  }


  /// ✅ Cancelar la suscripción al cerrar la app
  @override
  void dispose() {
    _gamesSubscription?.cancel();
    super.dispose();
  }
}

