import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generado por flutterfire

import 'package:provider/provider.dart';
import 'features/games/game_controller.dart';
import 'features/games/game_home_view.dart';
import 'features/auth/auth_page.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper ({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print(FirebaseAuth.instance.currentUser?.email);
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center (child: CircularProgressIndicator());
        }

        if (snapshot.hasData){
          return const GameHomeView();
      }else {
          return const AuthPage();
        }
      }
    );
  }
}
