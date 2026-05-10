import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  Future<void> saveUserData({
    required String role,
    required String nom,
    required String prenom,
    required String email,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('role', role);
    await prefs.setString('nom', nom);
    await prefs.setString('prenom', prenom);
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'role': prefs.getString('role') ?? '',
      'nom': prefs.getString('nom') ?? '',
      'prenom': prefs.getString('prenom') ?? '',
      'email': prefs.getString('email') ?? '',
      'token': prefs.getString('token') ?? '',
    };
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('nom');
    await prefs.remove('prenom');
    await prefs.remove('email');
  }
}