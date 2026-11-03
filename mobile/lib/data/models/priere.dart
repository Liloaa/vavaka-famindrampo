class Priere {
  final String id;
  final String titre;
  final String contenu;
  final int? numeroPage;
  final bool hasImage;
  final String? imageUrl;
  final String? categorieId;
  final String? categorieNom;

  Priere({
    required this.id,
    required this.titre,
    required this.contenu,
    this.numeroPage,
    this.hasImage = false,
    this.imageUrl,
    this.categorieId,
    this.categorieNom,
  });

  factory Priere.fromJson(Map<String, dynamic> json) => Priere(
        id: json['id'],
        titre: json['titre'],
        contenu: json['contenu'] ?? '',
        numeroPage: json['numero_page'],
        hasImage: json['has_image'] ?? false,
        imageUrl: json['image_url'],
        categorieId: json['categorie_id'],
        categorieNom: (json['categorie'] as Map<String, dynamic>?)?['nom'],
      );
}