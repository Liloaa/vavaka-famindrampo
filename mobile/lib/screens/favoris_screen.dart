import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/ouvrir_priere.dart';
import '../data/models/priere.dart';
import '../providers/favoris_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/favori_button.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavorisProvider>();
    final lib = context.watch<LibraryProvider>();

    final groupes = <String, List<Priere>>{};
    for (final id in fav.ids) {
      final p = lib.priere(id);
      final livreId = lib.livreDe(id);
      if (p == null || livreId == null) continue;
      groupes.putIfAbsent(livreId, () => []).add(p);
    }
    final total = groupes.values.fold<int>(0, (s, l) => s + l.length);

    return Scaffold(
      appBar: AppBar(title: Text('Mes favoris ($total)')),
      body: !fav.charge
          ? const Center(child: CircularProgressIndicator())
          : total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucun favori pour le moment.\nTouchez le cœur d\'une prière pour l\'ajouter.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final entree in groupes.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                        child: Text(
                          lib.livre(entree.key)?.titre ?? '',
                          style: TextStyle(
                            color: lib.couleurDuLivre(entree.key),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      for (final p in entree.value)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(p.titre,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (p.numeroPage != null)
                                  Text('Pg. ${p.numeroPage}',
                                      style: TextStyle(
                                          color: lib.couleurDuLivre(entree.key),
                                          fontWeight: FontWeight.w600)),
                                FavoriButton(priereId: p.id, size: 22),
                              ],
                            ),
                            onTap: () => ouvrirPriere(context,
                                livreId: entree.key, priereId: p.id),
                          ),
                        ),
                    ],
                  ],
                ),
    );
  }
}