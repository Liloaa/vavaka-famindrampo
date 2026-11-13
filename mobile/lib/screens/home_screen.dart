import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/livre.dart';
import '../data/services/image_cache.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import 'favoris_screen.dart';
import 'livre_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryProvider>();
    final modeNuit = context.watch<ThemeProvider>().modeNuit;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres de prières'),
        actions: [
          IconButton(
            icon: Icon(
              modeNuit ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: modeNuit ? 'Activer le mode jour' : 'Activer le mode nuit',
            onPressed: () => context.read<ThemeProvider>().basculer(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Mes favoris',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavorisScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          if (lib.synchro) const LinearProgressIndicator(minHeight: 2),
          if (lib.horsLigne && lib.aDonnees)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hors ligne : contenu enregistré sur le téléphone',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _contenu(context, lib)),
        ],
      ),
    );
  }

  Widget _contenu(BuildContext context, LibraryProvider lib) {
    if (!lib.pret) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!lib.aDonnees) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.cloud_download_outlined, size: 56),
                const SizedBox(height: 12),
                Text(
                  lib.synchro
                      ? 'Téléchargement des livres…\nCela peut prendre un moment la première fois.'
                      : 'Connectez-vous à internet une première fois pour télécharger les livres.',
                  textAlign: TextAlign.center,
                ),
                if (!lib.synchro) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => lib.synchroniser(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: lib.synchroniser,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: lib.livres.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _LivreCard(livre: lib.livres[i]),
      ),
    );
  }
}

class _LivreCard extends StatelessWidget {
  final Livre livre;
  const _LivreCard({required this.livre});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: livre.couleur.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LivreScreen(livre: livre)),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: livre.couleur, width: 6)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 90,
                  child: livre.couvertureUrl != null
                      ? CachedNetworkImage(
                          imageUrl: livre.couvertureUrl!,
                          cacheManager: CacheImages.manager,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livre.titre,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: livre.couleur,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${livre.nombrePrieres} prières',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: livre.couleur.withValues(alpha: 0.25),
        child: Icon(Icons.menu_book, color: livre.couleur),
      );
}
