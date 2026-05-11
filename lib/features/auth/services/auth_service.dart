import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse?> login(String email, String password) async {
    try {
      Response response = await _apiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'motDePasse': password,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

    Future<AuthResponse> register(String email, String motDePasse, String nom,String prenom) async {
      try {
        Response response = await _apiService.dio.post(
          '/auth/register',
          data: {
            'email': email,
            'motDePasse': motDePasse,
            'nom': nom,
            'prenom': prenom,
            'role': 'Role_STUDENT', // Default role for new users
          },
        );
  
        return AuthResponse.fromJson(response.data);
      } catch (e) {
        print(e);
        return AuthResponse.fromJson({'message': 'Registration failed'});
      }
    }
}