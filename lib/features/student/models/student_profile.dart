class StudentProfile {
  final String nom;
  final String prenom;
  final String email;

  StudentProfile({
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      nom: json['nom'] ?? 'Nom',
      prenom: json['prenom'] ?? 'Prénom',
      email: json['email'] ?? '',
    );
  }
  
  String get fullName => '$prenom $nom';
}
