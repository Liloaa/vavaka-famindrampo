import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import '../models/categorie.dart';
import '../models/livre.dart';
import '../models/priere.dart';

class ApiService {
  Future<Map<String, dynamic>> _get(String chemin) async {
    final res = await http
        .get(Uri.parse('${Env.apiUrl}$chemin'))
        .timeout(const Duration(seconds: 15));
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
}