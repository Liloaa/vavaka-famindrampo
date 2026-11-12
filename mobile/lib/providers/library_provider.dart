import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/utils/texte.dart';
import '../data/models/categorie.dart';
import '../data/models/livre.dart';
import '../data/models/priere.dart';
import '../data/models/resultat_recherche.dart';
import '../data/services/image_cache.dart';
import '../data/services/local_store.dart';
import '../data/services/sync_service.dart';

class LibraryProvider extends ChangeNotifier {
  List<Livre> _livres = [];
  final Map<String, Livre> _livreParId = {};
  final Map<String, List<Categorie>> _categories = {};
  final Map<String, List<Priere>> _prieres = {};
  final Map<String, Priere> _priereParId = {};
  final Map<String, String> _livreDePriere = {};
  final Map<String, String> _propre = {};
  final Map<String, String> _titreNorm = {};
  final Map<String, String> _contenuNorm = {};

  bool _pret = false;
  bool _synchro = false;
  bool _horsLigne = false;
  bool _imagesEnCours = false;

  List<Livre> get livres => _livres;
  bool get pret => _pret;
  bool get synchro => _synchro;
  bool get horsLigne => _horsLigne;
  bool get aDonnees => _livres.isNotEmpty;

  List<Categorie> categories(String livreId) => _categories[livreId] ?? const [];
  List<Priere> prieresDuLivre(String livreId) => _prieres[livreId] ?? const [];
  Priere? priere(String id) => _priereParId[id];
  String? livreDe(String priereId) => _livreDePriere[priereId];
  Livre? livre(String id) => _livreParId[id];
  Color couleurDuLivre(String id) =>
      _livreParId[id]?.couleur ?? const Color(0xFF8B0000);

  /// Appelé une fois au démarrage : lit le téléphone, puis synchronise.
  Future<void> init() async {
    await LocalStore.init();
    final local = LocalStore.lire('data');
    if (local != null) {
      try {
        _appliquer(local);
      } catch (_) {
        // copie locale illisible : on la ignore, la synchro la remplacera
      }
    }
    _pret = true;
    notifyListeners();
    await synchroniser();
  }

  Future<void> synchroniser() async {
    if (_synchro) return;
    _synchro = true;
    notifyListeners();
    try {
      final etag = LocalStore.lire('data') != null ? LocalStore.lire('etag') : null;
      final r = await SyncService.telecharger(etag: etag);
      _horsLigne = false;
      if (r.corps != null) {
        _appliquer(r.corps!);
        await LocalStore.ecrire('data', r.corps!);
        if (r.etag != null) await LocalStore.ecrire('etag', r.etag!);
      }
      _telechargerImages();
    } catch (_) {
      _horsLigne = true;
    }
    _synchro = false;
    notifyListeners();
  }

  void _appliquer(String corps) {
    final data = jsonDecode(corps) as Map<String, dynamic>;
    final lvs = (data['livres'] as List).cast<Map<String, dynamic>>();
    final cats = (data['categories'] as List).cast<Map<String, dynamic>>();
    final prs = (data['prieres'] as List).cast<Map<String, dynamic>>();

    final nomCat = {for (final c in cats) c['id'] as String: c['nom'] as String};

    final categories = <String, List<Categorie>>{};
    for (final c in cats) {
      categories
          .putIfAbsent(c['livre_id'] as String, () => [])
          .add(Categorie.fromJson(c));
    }

    final prieres = <String, List<Priere>>{};
    final parId = <String, Priere>{};
    final livreDe = <String, String>{};
    final propre = <String, String>{};
    final titreNorm = <String, String>{};
    final contenuNorm = <String, String>{};

    for (final p in prs) {
      final nom = nomCat[p['categorie_id']];
      final priere = Priere.fromJson({
        ...p,
        'categorie': nom == null ? null : {'nom': nom},
      });
      final livreId = p['livre_id'] as String;
      prieres.putIfAbsent(livreId, () => []).add(priere);
      parId[priere.id] = priere;
      livreDe[priere.id] = livreId;

      final texte = priere.contenu
          .replaceAll(RegExp(r'[*_#>]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      propre[priere.id] = texte;
      titreNorm[priere.id] = normaliser(priere.titre);
      contenuNorm[priere.id] = normaliser(texte);
    }

    final livres = [
      for (final l in lvs)
        Livre.fromJson({...l, 'nombre_prieres': prieres[l['id']]?.length ?? 0}),
    ];

    _livres = livres;
    _livreParId
      ..clear()
      ..addAll({for (final l in livres) l.id: l});
    _categories
      ..clear()
      ..addAll(categories);
    _prieres
      ..clear()
      ..addAll(prieres);
    _priereParId
      ..clear()
      ..addAll(parId);
    _livreDePriere
      ..clear()
      ..addAll(livreDe);
    _propre
      ..clear()
      ..addAll(propre);
    _titreNorm
      ..clear()
      ..addAll(titreNorm);
    _contenuNorm
      ..clear()
      ..addAll(contenuNorm);
  }

  Future<void> _telechargerImages() async {
    if (_imagesEnCours) return;
    _imagesEnCours = true;
    final urls = <String>{
      for (final l in _livres)
        if (l.couvertureUrl != null) l.couvertureUrl!,
      for (final liste in _prieres.values)
        for (final p in liste)
          if (p.imageUrl != null) p.imageUrl!,
    };
    for (final u in urls) {
      try {
        await CacheImages.manager.getSingleFile(u);
      } catch (_) {}
    }
    _imagesEnCours = false;
  }

  /// Recherche locale : titre, contenu ou numéro de page. Ignore les accents.
  List<ResultatRecherche> rechercher({String? q, int? page, String? livreId}) {
    final terme = normaliser((q ?? '').trim());
    if (terme.isEmpty && page == null) return const [];

    final res = <ResultatRecherche>[];
    for (final livre in _livres) {
      if (livreId != null && livre.id != livreId) continue;
      for (final p in _prieres[livre.id] ?? const <Priere>[]) {
        if (page != null && p.numeroPage != page) continue;
        if (terme.isNotEmpty) {
          final ok = _titreNorm[p.id]!.contains(terme) ||
              _contenuNorm[p.id]!.contains(terme);
          if (!ok) continue;
        }
        res.add(ResultatRecherche(
          id: p.id,
          titre: p.titre,
          extrait: _extrait(p.id, terme),
          numeroPage: p.numeroPage,
          livreId: livre.id,
          livreTitre: livre.titre,
          couleur: livre.couleur,
        ));
        if (res.length >= 100) return res;
      }
    }
    return res;
  }

  String _extrait(String id, String terme) {
    final propre = _propre[id] ?? '';
    final i = terme.isEmpty ? -1 : (_contenuNorm[id] ?? '').indexOf(terme);
    if (i < 0) {
      return propre.length > 100 ? '${propre.substring(0, 100)}…' : propre;
    }
    final debut = math.max(0, i - 40);
    final fin = math.min(propre.length, i + terme.length + 60);
    return '${debut > 0 ? '…' : ''}${propre.substring(debut, fin)}${fin < propre.length ? '…' : ''}';
  }
}