import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/game_model.dart';

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];

  // 💡 1. Se cambia a 'late' para asegurar que siempre tendrá un valor.
  late DateTime selectedDate;
  String searchText = '';

  String currentUserId = '';

  StreamSubscription? _gamesSubscription;

  GameController() {
    // 💡 2. LA CORRECCIÓN PRINCIPAL:
    // Se inicializa la fecha seleccionada con el día de hoy al crear el controlador.
    // Se normaliza la fecha para no incluir horas/minutos y asegurar comparaciones correctas.
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);

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
        // Asegúrate que tu GameModel.fromMap puede manejar el ID si lo necesitas
        return GameModel.fromMap(data);
      }).toList();

      applyFilters(); // El filtro se aplicará correctamente desde la primera vez.
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
    // Se normaliza la fecha para compararla correctamente.
    final newSelectedDate = DateTime(date.year, date.month, date.day);

    // 💡 3. Mejora: Evita trabajo innecesario si la fecha no ha cambiado.
    if (selectedDate == newSelectedDate) return;

    selectedDate = newSelectedDate;
    applyFilters();
  }

  /// 🔍 Cambiar texto de búsqueda
  void setSearchText(String text) {
    // 💡 3. Mejora: Evita trabajo innecesario si el texto de búsqueda no ha cambiado.
    if (searchText == text) return;

    searchText = text;
    applyFilters();
  }

  /// Aplica todos los filtros activos a la lista de juegos.
  void applyFilters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    filteredGames = allGames.where((game) {
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);

      // ⛔ Ocultar partidos pasados
      if (gameDay.isBefore(today)) return false;

      // ⛔ Ocultar partidos privados
      if (!game.isPublic) return false;

      // ⛔ Ocultar si el usuario ya está unido
      if (game.usersJoined.contains(currentUserId)) return false;

      // 💡 4. Lógica de filtro simplificada:
      // Ya no se necesita `if (selectedDate != null)` porque `selectedDate` siempre está inicializada.
      if (gameDay != selectedDate) return false;

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

      // Si pasa todos los filtros, el partido se incluye.
      return true;
    }).toList();

    // Notifica a los widgets que la lista de juegos filtrados ha cambiado.
    notifyListeners();
  }

  void setCurrentUser(String uid) {
    if (currentUserId == uid) return;
    currentUserId = uid;
    applyFilters(); // Actualiza la lista para ocultar los juegos a los que ya se unió.
  }

  /// ✅ Cancelar la suscripción al cerrar el widget para evitar fugas de memoria.
  @override
  void dispose() {
    _gamesSubscription?.cancel();
    super.dispose();
  }
}