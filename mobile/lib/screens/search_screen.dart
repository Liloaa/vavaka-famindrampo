import 'dart:async';
import 'package:flutter/material.dart';
import '../core/utils/couleur.dart';
import '../core/utils/ouvrir_priere.dart';
import '../data/models/livre.dart';
import '../data/models/resultat_recherche.dart';
import '../data/services/api_service.dart';
import '../widgets/favori_button.dart';
import '../widgets/texte_surligne.dart';

class SearchScreen extends StatefulWidget {
  final String? livreIdInitial;
  const SearchScreen({super.key, this.livreIdInitial});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Livre> _livres = [];
  String? _livreId;
  List<ResultatRecherche> _resultats = [];
  bool _enCours = false;
  bool _aCherche = false;
  String? _erreur;
  int _numRequete = 0;

  @override
  void initState() {
    super.initState();
    _livreId = widget.livreIdInitial;
    _api.getLivres().then((l) {
      if (mounted) setState(() => _livres = l);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  String get _texte => _ctrl.text.trim().replaceAll('’', "'");
  bool get _estPage => RegExp(r'^\d{1,4}$').hasMatch(_texte);

  void _surChangement(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _lancer);
  }

  Future<void> _lancer() async {
    final texte = _texte;
    if (texte.isEmpty) {
      setState(() {
        _resultats = [];
        _aCherche = false;
        _erreur = null;
        _enCours = false;
      });
      return;
    }
    if (!_estPage && texte.length < 2) return;

    final num = ++_numRequete;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final r = await _api.rechercher(
        q: _estPage ? null : texte,
        page: _estPage ? int.parse(texte) : null,
        livreId: _livreId,
      );
      if (!mounted || num != _numRequete) return;
      setState(() {
        _resultats = r;
        _aCherche = true;
        _enCours = false;
      });
    } catch (_) {
      if (!mounted || num != _numRequete) return;
      setState(() {
        _erreur = 'Recherche impossible. Vérifiez la connexion.';
        _enCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final terme = _estPage ? '' : _texte;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _surChangement,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _lancer(),
          decoration: InputDecoration(
            hintText: 'Titre, mot, ou numéro de page…',
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _ctrl.clear();
                      _lancer();
                    },
                  ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip('Tous les livres', null, Theme.of(context).colorScheme.primary),
                for (var i = 0; i < _livres.length; i++)
                  _chip('Livre ${i + 1}', _livres[i].id, _livres[i].couleur),
              ],
            ),
          ),
          if (_estPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recherche par numéro de page : $_texte',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          if (_enCours) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _corps(terme)),
        ],
      ),
    );
  }

  Widget _chip(String label, String? id, Color couleur) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _livreId == id,
        selectedColor: couleur.withValues(alpha: 0.2),
        onSelected: (_) {
          setState(() => _livreId = id);
          _lancer();
        },
      ),
    );
  }

  Widget _corps(String terme) {
    if (_erreur != null) {
      return Center(child: Text(_erreur!));
    }
    if (!_aCherche) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tapez un titre, un mot du texte ou un numéro de page.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_resultats.isEmpty) {
      return const Center(child: Text('Aucun résultat.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _resultats.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text('${_resultats.length} résultat(s)',
              style: Theme.of(context).textTheme.bodySmall);
        }
        final r = _resultats[i - 1];
        final c = couleurDepuisHex(r.couleurHex);
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: TexteSurligne(
              texte: r.titre,
              terme: terme,
              couleur: c,
              maxLines: 2,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(r.livreTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
                if (r.extrait.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  TexteSurligne(
                    texte: r.extrait,
                    terme: terme,
                    couleur: c,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (r.numeroPage != null)
                  Text('Pg. ${r.numeroPage}',
                      style: TextStyle(color: c, fontWeight: FontWeight.w600)),
                FavoriButton(priereId: r.id, size: 22),
              ],
            ),
            onTap: () => ouvrirPriere(context,
                livreId: r.livreId, priereId: r.id, couleur: c),
          ),
        );
      },
    );
  }
}