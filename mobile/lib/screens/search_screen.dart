import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/ouvrir_priere.dart';
import '../data/models/resultat_recherche.dart';
import '../providers/library_provider.dart';
import '../widgets/favori_button.dart';
import '../widgets/texte_surligne.dart';

class SearchScreen extends StatefulWidget {
  final String? livreIdInitial;
  const SearchScreen({super.key, this.livreIdInitial});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String? _livreId;

  @override
  void initState() {
    super.initState();
    _livreId = widget.livreIdInitial;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryProvider>();
    final texte = _ctrl.text.trim().replaceAll('’', "'");
    final estPage = RegExp(r'^\d{1,4}$').hasMatch(texte);
    final actif = texte.isNotEmpty && (estPage || texte.length >= 2);
    final terme = estPage ? '' : texte;

    final List<ResultatRecherche> resultats = actif
        ? lib.rechercher(
            q: estPage ? null : texte,
            page: estPage ? int.parse(texte) : null,
            livreId: _livreId,
          )
        : const <ResultatRecherche>[];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Titre, mot, ou numéro de page…',
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {});
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
                _chip('Tous les livres', null,
                    Theme.of(context).colorScheme.primary),
                for (var i = 0; i < lib.livres.length; i++)
                  _chip('Livre ${i + 1}', lib.livres[i].id, lib.livres[i].couleur),
              ],
            ),
          ),
          if (estPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recherche par numéro de page : $texte',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          Expanded(child: _corps(context, actif, resultats, terme)),
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
        onSelected: (_) => setState(() => _livreId = id),
      ),
    );
  }

  Widget _corps(BuildContext context, bool actif,
      List<ResultatRecherche> resultats, String terme) {
    if (!actif) {
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
    if (resultats.isEmpty) {
      return const Center(child: Text('Aucun résultat.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: resultats.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            resultats.length >= 100
                ? '100 premiers résultats'
                : '${resultats.length} résultat(s)',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final r = resultats[i - 1];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: TexteSurligne(
              texte: r.titre,
              terme: terme,
              couleur: r.couleur,
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
                    style: TextStyle(
                        color: r.couleur,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (r.extrait.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  TexteSurligne(
                    texte: r.extrait,
                    terme: terme,
                    couleur: r.couleur,
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
                      style: TextStyle(
                          color: r.couleur, fontWeight: FontWeight.w600)),
                FavoriButton(priereId: r.id, size: 22),
              ],
            ),
            onTap: () =>
                ouvrirPriere(context, livreId: r.livreId, priereId: r.id),
          ),
        );
      },
    );
  }
}