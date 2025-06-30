import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'features/games/game_home_view.dart';
import 'firebase_options.dart';
import 'features/games/game_controller.dart';
import 'features/auth/welcome_screen.dart';
import 'core/providers/theme_provider.dart';


import 'package:teamup/features/chat/change_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es_ES', null);
  runApp(const TeamUpApp());
}

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
            debugShowCheckedModeBanner: false,
            title: 'TeamUp',
            theme: ThemeData.light().copyWith(
              useMaterial3: true,
              primaryColor: Colors.cyan,
            ),
            darkTheme: ThemeData.dark().copyWith(
              useMaterial3: true,
              primaryColor: Colors.cyan,
            ),
            themeMode: themeProvider.themeMode,

            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData) {
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