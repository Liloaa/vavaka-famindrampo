import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';

class SyncReponse {
  final String? corps; // null = rien n'a changé
  final String? etag;
  const SyncReponse({this.corps, this.etag});
}

class SyncService {
  static Future<SyncReponse> telecharger({String? etag}) async {
    final res = await http.get(
      Uri.parse('${Env.apiUrl}/sync'),
      headers: {if (etag != null) 'If-None-Match': etag},
    ).timeout(const Duration(seconds: 90)); // laisse le temps à Render de se réveiller

    if (res.statusCode == 304) return const SyncReponse();
    if (res.statusCode != 200) {
      throw Exception('Erreur serveur (${res.statusCode})');
    }
    return SyncReponse(
      corps: utf8.decode(res.bodyBytes),
      etag: res.headers['etag'],
    );
  }
}