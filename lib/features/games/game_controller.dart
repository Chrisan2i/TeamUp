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

  // --- ESTADO GENERAL ---
  bool isLoading = false;
  List<GameModel> allGames = [];
  List<GameModel> filteredGames = [];
  String currentUserId = '';
  StreamSubscription? _gamesSubscription;

  // --- ESTADO DE LOS FILTROS ---
  late DateTime selectedDate;
  String searchText = '';
  Position? _userPosition;
  double _searchRadiusKm = 10;
  String? selectedZoneName;
  RangeValues _selectedHourRange = const RangeValues(8, 23);

  // --- ESTADO DE CARGA DE DATOS AUXILIARES ---
  bool isLoadingZones = false;
  List<ZoneModel> availableZones = [];

  // --- GETTERS PÚBLICOS (para acceder de forma segura al estado) ---
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


  void setCurrentUser(String uid) {
    if (currentUserId == uid) return;
    currentUserId = uid;
    applyFilters();
  }

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

  void setHourRange(RangeValues newRange) {
    if (_selectedHourRange == newRange) return;
    _selectedHourRange = newRange;
    applyFilters();
  }

  /// Resetea los filtros avanzados a sus valores por defecto y reaplica los filtros.
  void resetAdvancedFilters() {
    bool needsUpdate = false;

    if (selectedZoneName != null) {
      selectedZoneName = null;
      needsUpdate = true;
    }
    if (_selectedHourRange != const RangeValues(8, 23)) {
      _selectedHourRange = const RangeValues(8, 23);
      needsUpdate = true;
    }
    if (_searchRadiusKm != 10) {
      _searchRadiusKm = 10;
      needsUpdate = true;
    }

    // Solo notificar y aplicar filtros si algo realmente cambió
    if (needsUpdate) {
      applyFilters();
    }
  }

  // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ FIN DEL NUEVO MÉTODO ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

  // ===========================================================================
  // LÓGICA PRINCIPAL DE FILTRADO
  // ===========================================================================

  void applyFilters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<GameModel> tempFiltered = allGames;

    // 1. FILTRO POR ZONA (Aplicado primero si existe)
    if (selectedZoneName != null && selectedZoneName!.isNotEmpty) {
      tempFiltered = tempFiltered.where((game) => game.zone == selectedZoneName).toList();
    }

    // 2. FILTROS COMBINADOS DENTRO DE `.where()` PARA MEJOR RENDIMIENTO
    tempFiltered = tempFiltered.where((game) {
      // Filtros básicos de elegibilidad
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
      if (gameDay.isBefore(today)) return false;
      if (!game.isPublic) return false;
      if (game.usersJoined.contains(currentUserId)) return false;

      // Filtro de fecha
      if (gameDay != selectedDate) return false;

      // Filtro de RANGO DE HORAS
      try {
        final parts = game.hour.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final gameHourAsDouble = hour + (minute / 60.0);
          if (gameHourAsDouble < _selectedHourRange.start || gameHourAsDouble > _selectedHourRange.end) {
            return false;
          }
        }
      } catch (e) {
        debugPrint('Error al parsear la hora del partido ${game.id}: ${game.hour}. Se excluirá del filtro.');
        return false;
      }

      // Filtro de BÚSQUEDA POR TEXTO
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