import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../screens/priere_screen.dart';

Future<void> ouvrirPriere(
  BuildContext context, {
  required String livreId,
  required String priereId,
  required Color couleur,
}) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final prieres = await ApiService().getPrieres(livreId);
    final index = prieres.indexWhere((p) => p.id == priereId);
    if (index < 0) throw Exception('introuvable');
    navigator.push(MaterialPageRoute(
      builder: (_) => PriereScreen(prieres: prieres, index: index, couleur: couleur),
    ));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir la prière. Vérifiez la connexion.')),
    );
  }
}