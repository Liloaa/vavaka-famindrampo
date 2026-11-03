import 'package:flutter/material.dart';

class Livre {
  final String id;
  final String titre;
  final String? description;
  final String? couvertureUrl;
  final Color couleur;
  final int nombrePrieres;

  Livre({
    required this.id,
    required this.titre,
    this.description,
    this.couvertureUrl,
    required this.couleur,
    required this.nombrePrieres,
  });

  factory Livre.fromJson(Map<String, dynamic> json) => Livre(
        id: json['id'],
        titre: json['titre'],
        description: json['description'],
        couvertureUrl: json['couverture_url'],
        couleur: _parseCouleur(json['couleur_theme']),
        nombrePrieres: json['nombre_prieres'] ?? 0,
      );

  static Color _parseCouleur(String? hex) {
    final h = (hex ?? '#8B0000').replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}