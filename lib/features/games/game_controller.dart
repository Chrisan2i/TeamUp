// game_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';    // ← NUEVO
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

  // ── NUEVO: Geolocalización ───────────────────────────────────
  Position? _userPosition;
  double _searchRadiusKm = 10; // por defecto 10 km

  /// Permite al usuario cambiar el radio de búsqueda
  void setSearchRadius(double radiusKm) {
    _searchRadiusKm = radiusKm;
    applyFilters();
  }

  /// Expone el radio actual
  double get searchRadiusKm => _searchRadiusKm;
  // ─────────────────────────────────────────────────────────────

  GameController() {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);

    _listenToGames();
    // _getUserLocation();  // ← Desactivado temporalmente
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
      debugPrint('❌ Error escuchando juegos: \$e');
      isLoading = false;
      notifyListeners();
    });
  }

  /// Obtiene la ubicación del usuario (una sola vez)
  Future<void> _getUserLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Permiso de ubicación denegado.');
        return;
      }
      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      applyFilters(); // reaplica filtros con coordenadas
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicación: \$e');
    }
  }

  /// 📅 Cambiar fecha seleccionada
  void setDate(DateTime date) {
    final newSelectedDate = DateTime(date.year, date.month, date.day);
    if (selectedDate == newSelectedDate) return;
    selectedDate = newSelectedDate;
    applyFilters();
  }

  /// 🔍 Cambiar texto de búsqueda
  void setSearchText(String text) {
    if (searchText == text) return;
    searchText = text;
    applyFilters();
  }

  /// Aplica todos los filtros activos a la lista de juegos.
  void applyFilters() {
    // ── FILTRO POR DISTANCIA (Desactivado) ──────────────────────
    // if (_userPosition != null) {
    //   final userLat = _userPosition!.latitude;
    //   final userLng = _userPosition!.longitude;
    //   final radiusMeters = _searchRadiusKm * 1000;
    //   allGames = allGames.where((game) {
    //     final loc = game.location;
    //     if (loc == null) return false;
    //     final distance = Geolocator.distanceBetween(
    //         userLat, userLng, loc.latitude, loc.longitude);
    //     return distance <= radiusMeters;
    //   }).toList();
    // }
    // ─────────────────────────────────────────────────────────────

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    filteredGames = allGames.where((game) {
      final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
      if (gameDay.isBefore(today)) return false;
      if (!game.isPublic) return false;
      if (game.usersJoined.contains(currentUserId)) return false;
      if (gameDay != selectedDate) return false;

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
    if (currentUserId == uid) return;
    currentUserId = uid;
    applyFilters();
  }

  @override
  void dispose() {
    _gamesSubscription?.cancel();
    super.dispose();
  }
}

