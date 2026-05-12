class Course {
  final int id;
  final String titre;
  final String? description;
  final String? imageUrl;
  final String statut;
  final DateTime dateCreation;
  final double? prix;

  // Relations
  final int formateurId;
  final int? categorieId;

  const Course({
    required this.id,
    required this.titre,
    this.description,
    this.imageUrl,
    required this.statut,
    required this.dateCreation,
    this.prix,
    required this.formateurId,
    this.categorieId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      statut: json['statut'] ?? 'BROUILLON',
      dateCreation: DateTime.parse(json['dateCreation']),
      prix: json['prix'] != null
          ? (json['prix'] as num).toDouble()
          : null,

      // Relations
      formateurId: json['formateur'] != null
          ? json['formateur']['id']
          : 0,

      categorieId: json['categorie'] != null
          ? json['categorie']['id']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'imageUrl': imageUrl,
      'statut': statut,
      'dateCreation': dateCreation.toIso8601String(),
      'prix': prix,
      'formateurId': formateurId,
      'categorieId': categorieId,
    };
  }
}