class ResultatRecherche {
  final String id;
  final String titre;
  final String extrait;
  final int? numeroPage;
  final String livreId;
  final String livreTitre;
  final String couleurHex;

  ResultatRecherche({
    required this.id,
    required this.titre,
    required this.extrait,
    this.numeroPage,
    required this.livreId,
    required this.livreTitre,
    required this.couleurHex,
  });

  factory ResultatRecherche.fromJson(Map<String, dynamic> json) {
    final l = (json['livre'] as Map<String, dynamic>?) ?? {};
    return ResultatRecherche(
      id: json['id'],
      titre: json['titre'],
      extrait: json['extrait'] ?? '',
      numeroPage: json['numero_page'],
      livreId: l['id'] ?? '',
      livreTitre: l['titre'] ?? '',
      couleurHex: l['couleur_theme'] ?? '#8B0000',
    );
  }
}