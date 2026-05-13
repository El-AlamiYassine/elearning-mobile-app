import 'package:elearning/features/student/models/Category.dart';
import 'package:elearning/features/models/user_model.dart';

class Course {
  final int id;
  final String titre;
  final String? description;
  final String? imageUrl;
  final String statut;
  final DateTime dateCreation;
  final double? prix;

  // Relations
  final User formateur;
  final Category? categorie;

  const Course({
    required this.id,
    required this.titre,
    this.description,
    this.imageUrl,
    required this.statut,
    required this.dateCreation,
    this.prix,
    required this.formateur,
    this.categorie,
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
      formateur: User.fromJson(json['formateur']),

      categorie: json['categorie'] != null
          ? Category.fromJson(json['categorie'])
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
      'formateur': formateur.toJson(),
      'categorie': categorie?.toJson(),
    };
  }
}