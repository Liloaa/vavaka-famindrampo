import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favoris_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.charger();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavorisProvider()..charger()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const VavakaApp(),
    ),
  );
}

class VavakaApp extends StatelessWidget {
  const VavakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Vavaka Katolika',
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
        themeMode: themeProvider.modeNuit ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}