import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  final Dio dio;

  ApiService() : dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api', // Adjust base URL as needed (e.g., 10.0.2.2 for Android emulator)
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  ) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storageService = StorageService();
        final userData = await storageService.getUserData();
        final token = userData['token'];
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
}