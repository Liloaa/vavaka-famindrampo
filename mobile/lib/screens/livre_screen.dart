import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/livre.dart';
import '../providers/library_provider.dart';
import '../widgets/favori_button.dart';
import 'priere_screen.dart';
import 'search_screen.dart';

class LivreScreen extends StatefulWidget {
  final Livre livre;
  const LivreScreen({super.key, required this.livre});

  @override
  State<LivreScreen> createState() => _LivreScreenState();
}

class _LivreScreenState extends State<LivreScreen> {
  String? _categorieId;

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryProvider>();
    final couleur = widget.livre.couleur;
    final categories = lib.categories(widget.livre.id);
    final toutes = lib.prieresDuLivre(widget.livre.id);
    final prieres = _categorieId == null
        ? toutes
        : toutes.where((p) => p.categorieId == _categorieId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.livre.titre,
            maxLines: 2, style: const TextStyle(fontSize: 15)),
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher dans ce livre',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchScreen(livreIdInitial: widget.livre.id),
              ),
            ),
          ),
        ],
      ),
      body: toutes.isEmpty
          ? const Center(child: Text('Aucune prière pour le moment.'))
          : Column(
              children: [
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      children: [
                        _chip('Tous', null, couleur),
                        for (final c in categories) _chip(c.nom, c.id, couleur),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: prieres.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = prieres[i];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: Icon(Icons.auto_stories_outlined,
                              color: couleur),
                          title: Text(p.titre,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: p.categorieNom != null
                              ? Text(p.categorieNom!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (p.numeroPage != null)
                                Text('Pg. ${p.numeroPage}',
                                    style: TextStyle(
                                        color: couleur,
                                        fontWeight: FontWeight.w600)),
                              FavoriButton(priereId: p.id, size: 22),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PriereScreen(
                                prieres: prieres,
                                index: i,
                                couleur: couleur,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String label, String? id, Color couleur) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _categorieId == id,
        selectedColor: couleur.withValues(alpha: 0.2),
        onSelected: (_) => setState(() => _categorieId = id),
      ),
    );
  }
}