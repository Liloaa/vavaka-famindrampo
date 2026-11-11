import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/couleur.dart';
import '../core/utils/ouvrir_priere.dart';
import '../data/models/favori.dart';
import '../providers/favoris_provider.dart';
import '../widgets/favori_button.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavorisProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Mes favoris (${fav.favoris.length})')),
      body: RefreshIndicator(
        onRefresh: fav.charger,
        child: _corps(context, fav),
      ),
    );
  }

  Widget _corps(BuildContext context, FavorisProvider fav) {
    if (!fav.charge) {
      return const Center(child: CircularProgressIndicator());
    }
    if (fav.favoris.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.favorite_border, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Center(
            child: Text(
              fav.erreur ?? 'Tsy misy favori ny amin\'izao.\nKitiho any anaty vavaka any mba hampiditra.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    final groupes = <String, List<Favori>>{};
    for (final f in fav.favoris) {
      groupes.putIfAbsent(f.livreId, () => []).add(f);
    }

    final widgets = <Widget>[];
    groupes.forEach((_, liste) {
      final c = couleurDepuisHex(liste.first.couleurHex);
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Text(
          liste.first.livreTitre,
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ));
      for (final f in liste) {
        widgets.add(Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(f.titre, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (f.numeroPage != null)
                  Text('Pg. ${f.numeroPage}',
                      style: TextStyle(color: c, fontWeight: FontWeight.w600)),
                FavoriButton(priereId: f.priereId, size: 22),
              ],
            ),
            onTap: () => ouvrirPriere(context,
                livreId: f.livreId, priereId: f.priereId, couleur: c),
          ),
        ));
      }
    });

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: widgets,
    );
  }
}