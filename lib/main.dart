import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generado por flutterfire

import 'package:provider/provider.dart';
import 'features/games/game_controller.dart';
import 'features/games/game_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        home: const GameHomeView(),
      ),
    );
  }
}
