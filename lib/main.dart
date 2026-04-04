import 'package:flutter/material.dart';
import 'package:liminal_app/screens/home_screen.dart';
import 'package:liminal_app/screens/list_screen.dart';
import 'package:liminal_app/screens/calendar_screen.dart';
import 'package:liminal_app/screens/cruds_screen.dart';

import 'package:liminal_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Importante

  // Inicializamos notificaciones
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
        "/list": (context) => ListScreen(),
        "/calendar": (context) => CalendarScreen(),
        "/cruds": (context) => CrudsScreen(),
        "/home": (context) => Home(),
      },
    );
  }
}
