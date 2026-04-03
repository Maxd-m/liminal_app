import 'package:flutter/material.dart';
import 'package:liminal_app/screens/home_screen.dart';
import 'package:liminal_app/screens/list_screen.dart';

void main() {
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
      routes: {"/list": (context) => ListScreen()},
    );
  }
}
