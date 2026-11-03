class Categorie {
  final String id;
  final String nom;

  Categorie({required this.id, required this.nom});

  factory Categorie.fromJson(Map<String, dynamic> json) =>
      Categorie(id: json['id'], nom: json['nom']);
}