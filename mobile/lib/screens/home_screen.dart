import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../data/models/livre.dart';
import '../data/services/api_service.dart';
import 'livre_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late Future<List<Livre>> _livres;

  @override
  void initState() {
    super.initState();
    _livres = _api.getLivres();
  }

  Future<void> _recharger() async {
    final f = _api.getLivres();
    setState(() => _livres = f);
    try {
      await f;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livres de prières')),
      body: FutureBuilder<List<Livre>>(
        future: _livres,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Impossible de charger les livres.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _recharger, child: const Text('Réessayer')),
                  ],
                ),
              ),
            );
          }
          final livres = snap.data!;
          return RefreshIndicator(
            onRefresh: _recharger,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: livres.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _LivreCard(livre: livres[i]),
            ),
          );
        },
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