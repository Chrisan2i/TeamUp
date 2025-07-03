// Puedes crear un archivo como: lib/core/utils/launcher_helper.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre una conversación de WhatsApp con un número y mensaje predefinidos.
///
/// Muestra un SnackBar en caso de error.
Future<void> launchWhatsApp({
  required BuildContext context,
  required String phoneNumber,
  required String message,
}) async {
  // Codifica el mensaje para que sea seguro en una URL
  final String encodedMessage = Uri.encodeComponent(message);

  // Construye la URL de la API de WhatsApp
  final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');

  try {
    // Intenta lanzar la URL. `launchUrl` se encargará de abrir la app de WhatsApp
    // si está instalada, o el navegador web si no lo está.
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication, // Pide al sistema operativo abrir la app externa
      );
    } else {
      // Si por alguna razón no se puede lanzar la URL
      throw 'No se pudo abrir WhatsApp.';
    }
  } catch (e) {
    // Muestra un mensaje de error amigable al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al abrir WhatsApp: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}