import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../models/auth_response.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? role;
  String? nom;
  String? prenom;
  String? email;
  String? token;

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    Map<String, String> userData = await _storageService.getUserData();
    role = userData['role'];
    nom = userData['nom'];
    prenom = userData['prenom'];
    email = userData['email'];
    token = userData['token'];

    notifyListeners();
  }

  Future<bool> login(String email,String password,) async {
    isLoading = true;
    notifyListeners();

    AuthResponse? authResponse = await _authService.login(email,password,);

    isLoading = false;

    if (authResponse != null) {
      await _storageService.saveUserData(
        role: authResponse.role,
        nom: authResponse.nom,
        prenom: authResponse.prenom,
        email: authResponse.email,
        token: authResponse.token,
      );

      role = authResponse.role;

      notifyListeners();

      return true;
    }

    notifyListeners();

    return false;
  }

  Future<bool> register(String email,String password,String nom,String prenom,) async {
    isLoading = true;
    notifyListeners();

    AuthResponse authResponse =await _authService.register(email,password,nom,prenom,);

    isLoading = false;

    await _storageService.saveUserData(
      role: authResponse.role,
      nom: authResponse.nom,
      prenom: authResponse.prenom,
      email: authResponse.email,
      token: authResponse.token,
    );

    role = authResponse.role;

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    await _storageService.clearAll();

    role = null;

    notifyListeners();
  }

  bool get isAuthenticated {
    return role != null;
  }
}