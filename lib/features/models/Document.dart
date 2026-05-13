class Document {
  final int? id;
  final String nom;
  final String cheminFichier;
  final int? taille;
  final String type;
  final DateTime dateUpload;

  // relation simplifiée (on garde juste l'id côté Flutter)
  final int lessonId;

  Document({
    this.id,
    required this.nom,
    required this.cheminFichier,
    this.taille,
    this.type = "application/pdf",
    DateTime? dateUpload,
    required this.lessonId,
  }) : dateUpload = dateUpload ?? DateTime.now();

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      nom: json['nom'] ?? '',
      cheminFichier: json['cheminFichier'] ?? '',
      taille: json['taille'],
      type: json['type'] ?? 'application/pdf',

      dateUpload: json['dateUpload'] != null
          ? DateTime.parse(json['dateUpload'])
          : DateTime.now(),

      // backend relation (lesson object or id)
      lessonId: json['lesson'] != null
          ? json['lesson']['id']
          : json['lessonId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'cheminFichier': cheminFichier,
      'taille': taille,
      'type': type,
      'dateUpload': dateUpload.toIso8601String(),

      // backend expects ID
      'lessonId': lessonId,
    };
  }
}