import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const VavakaApp());

class VavakaApp extends StatelessWidget {
  const VavakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vavaka Famindrapo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0C447C),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}