import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>('bibliotheque');
  }

  static String? lire(String cle) => _box?.get(cle);

  static Future<void> ecrire(String cle, String valeur) async {
    await _box?.put(cle, valeur);
  }
}