import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import '../models/categorie.dart';
import '../models/favori.dart';
import '../models/livre.dart';
import '../models/priere.dart';
import '../models/resultat_recherche.dart';

class ApiService {
  static const _delai = Duration(seconds: 15);

  Future<Map<String, dynamic>> _get(String chemin,
      [Map<String, String>? params]) async {
    final uri =
        Uri.parse('${Env.apiUrl}$chemin').replace(queryParameters: params);
    final res = await http.get(uri).timeout(_delai);
    if (res.statusCode != 200) {
      throw Exception('Erreur serveur (${res.statusCode})');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<List<Livre>> getLivres() async {
    final data = await _get('/livres');
    return (data['livres'] as List).map((e) => Livre.fromJson(e)).toList();
  }

  Future<List<Categorie>> getCategories(String livreId) async {
    final data = await _get('/livres/$livreId/categories');
    return (data['categories'] as List)
        .map((e) => Categorie.fromJson(e))
        .toList();
  }

  Future<List<Priere>> getPrieres(String livreId) async {
    final data = await _get('/livres/$livreId/prieres');
    return (data['prieres'] as List).map((e) => Priere.fromJson(e)).toList();
  }

  Future<List<ResultatRecherche>> rechercher(
      {String? q, int? page, String? livreId}) async {
    final params = <String, String>{};
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    if (page != null) params['page'] = page.toString();
    if (livreId != null) params['livre_id'] = livreId;
    final data = await _get('/search', params);
    return (data['resultats'] as List)
        .map((e) => ResultatRecherche.fromJson(e))
        .toList();
  }

  Future<List<Favori>> getFavoris(String deviceId) async {
    final data = await _get('/favoris/$deviceId');
    return (data['favoris'] as List).map((e) => Favori.fromJson(e)).toList();
  }

  Future<void> ajouterFavori(String deviceId, String priereId) async {
    final res = await http
        .post(
          Uri.parse('${Env.apiUrl}/favoris'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'priere_id': priereId, 'device_id': deviceId}),
        )
        .timeout(_delai);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erreur serveur (${res.statusCode})');
    }
  }

  Future<void> supprimerFavori(String deviceId, String favoriId) async {
    final uri = Uri.parse('${Env.apiUrl}/favoris/$favoriId')
        .replace(queryParameters: {'device_id': deviceId});
    final res = await http.delete(uri).timeout(_delai);
    if (res.statusCode != 200) {
      throw Exception('Erreur serveur (${res.statusCode})');
    }
  }
}