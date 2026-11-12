import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavorisProvider extends ChangeNotifier {
  final List<String> _ids = []; // le plus récent en premier
  bool _charge = false;

  List<String> get ids => List.unmodifiable(_ids);
  bool get charge => _charge;

  bool estFavori(String priereId) => _ids.contains(priereId);

  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList('favoris') ?? const []);
    _charge = true;
    notifyListeners();
  }

  /// Ajoute ou retire un favori. Renvoie false si l'enregistrement a échoué.
  Future<bool> basculer(String priereId) async {
    if (!_ids.remove(priereId)) _ids.insert(0, priereId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favoris', _ids);
      return true;
    } catch (_) {
      return false;
    }
  }
}