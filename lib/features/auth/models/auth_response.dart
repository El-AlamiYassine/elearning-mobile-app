class AuthResponse {
  final String token;
  final String role;
  final String message;
  final String nom;
  final String prenom;
  final String email;

  AuthResponse({
    required this.token,
    required this.role,
    required this.message,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      role: json['role'],
      message: json['message'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
    );
  }
}
