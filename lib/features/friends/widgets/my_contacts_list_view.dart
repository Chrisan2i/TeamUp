// lib/features/friends/widgets/my_contacts_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';

class MyContactsListView extends StatefulWidget {
  const MyContactsListView({super.key});

  @override
  State<MyContactsListView> createState() => _MyContactsListViewState();
}

class _MyContactsListViewState extends State<MyContactsListView> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _fetchContacts();
  }

  Future<List<Contact>> _fetchContacts() async {
    // Solicita permiso y, si se concede, carga contactos sin miniaturas
    if (await FlutterContacts.requestPermission()) {
      return FlutterContacts.getContacts(
        withProperties: true,    // para incluir teléfonos
        withThumbnail: false,
      );
    } else {
      throw Exception('Permiso de contactos denegado.');
    }
  }

  void _shareInvitation() {
    Share.share(
      '¡Hola! Únete a mí en TeamUp, la mejor app para organizar partidos. '
          'Descárgala aquí: [Tu Enlace a la App]',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0CC0DF)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No se pudo cargar los contactos. Por favor, verifica los permisos en la configuración de tu teléfono.\n'
                    'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final contacts = snapshot.data;
        if (contacts == null || contacts.isEmpty) {
          return const Center(
            child: Text('No se encontraron contactos en tu dispositivo.'),
          );
        }

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final name = contact.displayName;
            if (name == null || name.isEmpty) {
              return const SizedBox.shrink();
            }

            final phone = contact.phones.isNotEmpty
                ? contact.phones.first.number
                : 'Sin número';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0CC0DF),
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(name),
              subtitle: Text(phone),
              trailing: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF0CC0DF)),
                onPressed: _shareInvitation,
              ),
            );
          },
        );
      },
    );
  }
}
