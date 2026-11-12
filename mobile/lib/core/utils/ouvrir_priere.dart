import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../screens/priere_screen.dart';

void ouvrirPriere(
  BuildContext context, {
  required String livreId,
  required String priereId,
}) {
  final lib = context.read<LibraryProvider>();
  final liste = lib.prieresDuLivre(livreId);
  final index = liste.indexWhere((p) => p.id == priereId);
  if (index < 0) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PriereScreen(
        prieres: liste,
        index: index,
        couleur: lib.couleurDuLivre(livreId),
      ),
    ),
  );
}