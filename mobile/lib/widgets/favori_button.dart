import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favoris_provider.dart';

class FavoriButton extends StatelessWidget {
  final String priereId;
  final Color couleurInactive;
  final double size;

  const FavoriButton({
    super.key,
    required this.priereId,
    this.couleurInactive = Colors.grey,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final est = context.watch<FavorisProvider>().estFavori(priereId);
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: size,
      tooltip: est ? 'Retirer des favoris' : 'Ajouter aux favoris',
      icon: Icon(
        est ? Icons.favorite : Icons.favorite_border,
        color: est ? Colors.pinkAccent : couleurInactive,
      ),
      onPressed: () async {
        final ok = await context.read<FavorisProvider>().basculer(priereId);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action impossible. Vérifiez la connexion.')),
          );
        }
      },
    );
  }
}