import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favoris_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => FavorisProvider()..charger(),
        child: const VavakaApp(),
      ),
    );

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