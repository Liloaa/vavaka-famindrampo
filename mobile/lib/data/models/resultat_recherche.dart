import 'package:flutter/material.dart';

class ResultatRecherche {
  final String id;
  final String titre;
  final String extrait;
  final int? numeroPage;
  final String livreId;
  final String livreTitre;
  final Color couleur;

  const ResultatRecherche({
    required this.id,
    required this.titre,
    required this.extrait,
    this.numeroPage,
    required this.livreId,
    required this.livreTitre,
    required this.couleur,
  });
}