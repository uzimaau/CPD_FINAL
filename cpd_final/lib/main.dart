import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cpd_final/pages/home_page.dart';
import 'package:cpd_final/pages/game_form_page.dart';
import 'package:cpd_final/pages/game_list_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart'; // Generated via `flutterfire configure`

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(GameTrackerApp());
}

class GameTrackerApp extends StatelessWidget {
  const GameTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Tracker',
      theme: ThemeData(primarySwatch: Colors.purple),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/form': (context) => const GameFormPage(),
        '/games': (context) => const GameListPage(),
      },
    );
  }
}
