import 'Role.dart';
class User {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final Role role;
  final bool actif;
  final DateTime dateCreation;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.role,
    this.actif = true,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// 🔁 JSON → Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      motDePasse: json['motDePasse'] ?? json['mot_de_passe'],
      role: _roleFromString(json['role']),
      actif: json['actif'] ?? true,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
    );
  }

  /// 🔁 Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.name,
      'actif': actif,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  /// 🔧 Convert String → Enum
  static Role _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'role_admin':
        return Role.ROLE_ADMIN;
      case 'role_teacher':
        return Role.ROLE_TEACHER;
      case 'role_student':
        return Role.ROLE_STUDENT;
      default:
        return Role.ROLE_STUDENT;
    }
  }
}