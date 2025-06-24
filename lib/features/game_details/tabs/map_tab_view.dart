// lib/features/game_details/tabs/map_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:teamup/models/game_model.dart';

class MapTabView extends StatelessWidget {
  final GameModel game;
  const MapTabView({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lat = game.location?.latitude ?? 0.0;
    final lng = game.location?.longitude ?? 0.0;

    Future<void> _launchMaps() async {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.fieldName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Si no tienes game.address, mantenemos un placeholder:
          Text("Ubicación aproximada",
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.directions_car_filled, color: Colors.blue),
            title: const Text('Obtener rutas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _launchMaps,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey.shade100,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("WHERE TO FIND US",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  "Once you arrive at the facility, ask the employee for the '${game.description}' game...",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(lat, lng),
                  zoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.yourcompany.teamup',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(lat, lng),
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
