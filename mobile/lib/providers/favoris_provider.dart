import 'package:flutter/foundation.dart';
import '../core/utils/device_id.dart';
import '../data/models/favori.dart';
import '../data/services/api_service.dart';

class FavorisProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Favori> _favoris = [];
  bool _charge = false;
  String? _erreur;
  String? _deviceId;

  List<Favori> get favoris => _favoris;
  bool get charge => _charge;
  String? get erreur => _erreur;

  bool estFavori(String priereId) => _favoris.any((f) => f.priereId == priereId);

  Future<void> charger() async {
    try {
      _deviceId ??= await DeviceId.get();
      _favoris = await _api.getFavoris(_deviceId!);
      _erreur = null;
    } catch (_) {
      _erreur = 'Impossible de charger les favoris.';
    }
    _charge = true;
    notifyListeners();
  }

  /// Ajoute ou retire un favori. Renvoie false en cas d'échec.
  Future<bool> basculer(String priereId) async {
    final id = _deviceId ??= await DeviceId.get();
    final existants = _favoris.where((f) => f.priereId == priereId).toList();
    try {
      if (existants.isNotEmpty) {
        await _api.supprimerFavori(id, existants.first.id);
        _favoris.removeWhere((f) => f.priereId == priereId);
        notifyListeners();
      } else {
        await _api.ajouterFavori(id, priereId);
        await charger();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}