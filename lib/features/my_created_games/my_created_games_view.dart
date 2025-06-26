// lib/features/my_games/my_created_games_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el UID del usuario
import '../../models/game_model.dart'; // Asegúrate que la ruta sea correcta
import 'widgets/game_list_item_card.dart';


class MyCreatedGamesView extends StatefulWidget {
  const MyCreatedGamesView({super.key});

  @override
  State<MyCreatedGamesView> createState() => _MyCreatedGamesViewState();
}

class _MyCreatedGamesViewState extends State<MyCreatedGamesView> {
  String? _activeFilter;

  static final Map<String, ({Color background, Color text})> _statusStyles = {
    'pending': (background: const Color(0xFFFEF3C7), text: const Color(0xFF92400E)),
    'confirmed': (background: const Color(0xFFD1FAE5), text: const Color(0xFF065F46)),
    'cancelled': (background: const Color(0xFFFEE2E2), text: const Color(0xFF991B1B)),
  };

  /// Muestra un panel modal en la parte inferior para que el usuario seleccione un filtro.
  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterOptions(),
    );

    if (result != null) {
      setState(() {
        _activeFilter = result == 'all' ? null : result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error de Autenticación")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Por favor, inicia sesión para ver tus partidos creados.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mis Partidos Creados',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Filtrar partidos',
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _showFilterSheet,
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getGamesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ha ocurrido un error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has creado ningún partido.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final games = snapshot.data!.docs
              .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              return GameListItemCard(game: games[index]);
            },
          );
        },
      ),
    );
  }

  /// Construye y devuelve el stream de Firestore basado en el UID del usuario y el filtro activo.
  Stream<QuerySnapshot> _getGamesStream(String userId) {
    Query query = FirebaseFirestore.instance
        .collection('games')
        .where('ownerId', isEqualTo: userId)
        .orderBy('date', descending: true); // Muestra los partidos más recientes primero

    if (_activeFilter != null) {
      // Si hay un filtro activo, añade una cláusula 'where' adicional a la consulta.
      query = query.where('status', isEqualTo: _activeFilter);
    }

    return query.snapshots();
  }

  /// Construye el contenido del panel modal de filtros.
  Widget _buildFilterOptions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Filtrar por estado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Todos los partidos'),
              onTap: () => Navigator.of(context).pop('all'),
            ),
            ListTile(
              leading: Icon(Icons.pending_actions_outlined, color: _statusStyles['pending']?.text),
              title: const Text('Pendientes'),
              onTap: () => Navigator.of(context).pop('pending'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: _statusStyles['confirmed']?.text),
              title: const Text('Confirmados'),
              onTap: () => Navigator.of(context).pop('confirmed'),
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: _statusStyles['cancelled']?.text),
              title: const Text('Cancelados'),
              onTap: () => Navigator.of(context).pop('cancelled'),
            ),
          ],
        ),
      ),
    );
  }
}