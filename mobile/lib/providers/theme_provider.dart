import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _cleModeNuit = 'mode_nuit';

  bool _modeNuit = false;

  bool get modeNuit => _modeNuit;

  Future<void> charger() async {
    final preferences = await SharedPreferences.getInstance();
    _modeNuit = preferences.getBool(_cleModeNuit) ?? false;
    notifyListeners();
  }

  Future<void> basculer() async {
    final preferences = await SharedPreferences.getInstance();
    final nouveauMode = !_modeNuit;
    final enregistre = await preferences.setBool(_cleModeNuit, nouveauMode);
    if (!enregistre) {
      throw StateError('Impossible d’enregistrer le thème choisi.');
    }
    _modeNuit = nouveauMode;
    notifyListeners();
  }
}
