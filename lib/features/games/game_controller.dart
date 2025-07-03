// lib/features/games/game_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Asegúrate de que las rutas de importación sean correctas
import '../../models/game_model.dart';
import '../../models/zone_model.dart';

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];

  // --- Filtros de estado ---
  late DateTime selectedDate;
  String searchText = '';
  String currentUserId = '';
  StreamSubscription? _gamesSubscription;
  Position? _userPosition;
  double _searchRadiusKm = 10;
  String? selectedZoneName;
  bool isLoadingZones = false;
  List<ZoneModel> availableZones = [];

  RangeValues _selectedHourRange = const RangeValues(8, 23);


  double get searchRadiusKm => _searchRadiusKm;
  RangeValues get selectedHourRange => _selectedHourRange;

  GameController() {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);

    // Iniciar la carga de datos
    _listenToGames();
    fetchZones();
  }

  @override
  void dispose() {
    _gamesSubscription?.cancel();
    super.dispose();
  }


  void _listenToGames() {
    isLoading = true;
    notifyListeners();

    _gamesSubscription = _firestore
        .collection('games')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      allGames = snapshot.docs.map((doc) => GameModel.fromMap(doc.data())).toList();
      applyFilters();
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Error escuchando juegos: $e');
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchZones() async {
    isLoadingZones = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('zones').get();
      availableZones = snapshot.docs.map((doc) => ZoneModel.fromFirestore(doc)).toList();
      availableZones.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('❌ Error al cargar las zonas: $e');
    } finally {
      isLoadingZones = false;
      notifyListeners();
    }
  }

  // --- Métodos para actualizar los filtros ---

  void setDate(DateTime date) {
    final newSelectedDate = DateTime(date.year, date.month, date.day);
    if (selectedDate == newSelectedDate) return;
    selectedDate = newSelectedDate;
    applyFilters();
  }

  void setSearchText(String text) {
    if (searchText == text.toLowerCase()) return;
    searchText = text.toLowerCase();
    applyFilters();
  }

  void setSearchRadius(double radiusKm) {
    _searchRadiusKm = radiusKm;
    applyFilters();
  }

  void setZoneFilter(String? zoneName) {
    if (selectedZoneName == zoneName) return;
    selectedZoneName = zoneName;
    applyFilters();
  }

  void setCurrentUser(String uid) {
    if (currentUserId == uid) return;
    currentUserId = uid;
    applyFilters();
  }


  void setHourRange(RangeValues newRange) {
    if (_selectedHourRange == newRange) return;
    _selectedHourRange = newRange;
    applyFilters();
  }


  void applyFilters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<GameModel> tempFiltered = allGames;

    // 1. FILTRO POR ZONA
    if (selectedZoneName != null && selectedZoneName!.isNotEmpty) {
      tempFiltered = tempFiltered.where((game) => game.zone == selectedZoneName).toList();
    }

    // 2. FILTRO POR DISTANCIA (si está activo)
    // if (_userPosition != null) { ... }

    // 3. FILTROS COMBINADOS DENTRO DE `.where()` PARA MEJOR RENDIMIENTO
    tempFiltered = tempFiltered.where((game) {
      // Filtro de fecha y estado
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
      if (gameDay.isBefore(today)) return false;
      if (!game.isPublic) return false;
      if (game.usersJoined.contains(currentUserId)) return false;
      if (gameDay != selectedDate) return false;

      // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ LÓGICA DE FILTRADO POR HORA INTEGRADA ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
      try {
        final parts = game.hour.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          // Convertimos "19:30" a un valor numérico como 19.5 para compararlo
          final gameHourAsDouble = hour + (minute / 60.0);

          // Comprobamos si la hora del partido está DENTRO del rango seleccionado
          if (gameHourAsDouble < _selectedHourRange.start || gameHourAsDouble > _selectedHourRange.end) {
            return false; // El partido está FUERA del rango, lo descartamos.
          }
        }
      } catch (e) {

        debugPrint('Error al parsear la hora del partido ${game.id}: ${game.hour}. Se excluirá del filtro.');
        return false;
      }

      // Filtro de texto
      if (searchText.isNotEmpty) {
        final search = searchText.toLowerCase();
        final matchesField = game.fieldName.toLowerCase().contains(search);
        final matchesDescription = game.description.toLowerCase().contains(search);
        final matchesZone = game.zone.toLowerCase().contains(search);
        if (!matchesField && !matchesDescription && !matchesZone) {
          return false;
        }
      }

      // Si el partido pasó todos los filtros, lo incluimos.
      return true;
    }).toList();

    filteredGames = tempFiltered;
    notifyListeners();
  }
}