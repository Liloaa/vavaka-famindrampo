import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favoris_provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LibraryProvider()..init()),
          ChangeNotifierProvider(create: (_) => FavorisProvider()..charger()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()..charger()),
        ],
        child: const VavakaApp(),
      ),
    );

class VavakaApp extends StatelessWidget {
  const VavakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modeNuit = context.watch<ThemeProvider>().modeNuit;
    return MaterialApp(
      title: 'Vavaka Famindrapo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0C447C),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF0C447C),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: modeNuit ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
