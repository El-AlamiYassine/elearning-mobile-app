class Category {
  final int id;
  final String nom;
  final String description;

  const Category({
    required this.id,
    required this.nom,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
    );
  }

  get coursesCount => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
    };
  }
}