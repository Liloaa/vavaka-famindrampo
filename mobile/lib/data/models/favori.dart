class Favori {
  final String id;
  final String priereId;
  final String titre;
  final int? numeroPage;
  final String livreId;
  final String livreTitre;
  final String couleurHex;

  Favori({
    required this.id,
    required this.priereId,
    required this.titre,
    this.numeroPage,
    required this.livreId,
    required this.livreTitre,
    required this.couleurHex,
  });

  factory Favori.fromJson(Map<String, dynamic> json) {
    final p = json['prieres'] as Map<String, dynamic>;
    final l = (p['livres'] as Map<String, dynamic>?) ?? {};
    return Favori(
      id: json['id'],
      priereId: p['id'],
      titre: p['titre'],
      numeroPage: p['numero_page'],
      livreId: p['livre_id'],
      livreTitre: l['titre'] ?? '',
      couleurHex: l['couleur_theme'] ?? '#8B0000',
    );
  }
}