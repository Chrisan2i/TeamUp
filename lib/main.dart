import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:teamup/firebase_options.dart';
import 'package:teamup/core/providers/theme_provider.dart';
import 'package:teamup/features/auth/welcome_screen.dart';
import 'package:teamup/features/games/game_controller.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/features/chat/change_notifier.dart';

/// Punto de entrada principal de la aplicación.
///
/// Se encarga de:
/// 1. Inicializar los bindings de Flutter.
/// 2. Inicializar Firebase.
/// 3. Inicializar el formato de fecha para el idioma español.
/// 4. Ejecutar la aplicación principal `TeamUpApp`.
void main() async {
  // Asegura que todos los bindings de Flutter estén listos antes de ejecutar código nativo.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase utilizando las opciones de configuración específicas de la plataforma.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa los datos de localización para el formato de fecha en español.
  // Esencial para que widgets como el GameDateSelector muestren "Lunes", "Martes", etc.
  await initializeDateFormatting('es_ES', null);

  // Inicia la aplicación.
  runApp(const TeamUpApp());
}

/// El widget raíz de la aplicación TeamUp.
///
/// Configura:
/// 1. `MultiProvider` para la gestión de estado global (GameController, ThemeProvider, etc.).
/// 2. `MaterialApp` para la configuración del tema, rutas y la navegación inicial.
/// 3. `StreamBuilder` para reaccionar a los cambios de estado de autenticación de Firebase.
class TeamUpApp extends StatelessWidget {
  const TeamUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => ChatNotifier()),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'TeamUp',

            debugShowCheckedModeBanner: false,


            theme: ThemeData( // Tema Claro
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0CC0DF),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF8FAFC),
                foregroundColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0CC0DF),
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeMode, // Controlado por el ThemeProvider


            home: StreamBuilder<User?>(

              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return const GameHomeView();
                } else {
                  return const WelcomeScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}