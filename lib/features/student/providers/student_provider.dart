import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/student_profile.dart';
import '../services/student_service.dart';
import '../../../core/services/storage_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  final StorageService _storageService = StorageService();
  StudentProfile? profile;
  List<CourseModel> courses = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch both profile and courses in parallel if possible, or sequentially
      final userData = await StorageService().getUserData();
      final fetchedCourses = await _studentService.getEnrolledCourses();
      profile = StudentProfile.fromJson(userData);
      courses = fetchedCourses;
      
      // Fallback values if profile is null (in case the API is not fully implemented yet)

    profile ??= StudentProfile(
        nom: userData['nom']!,  
        prenom: userData['prenom']!,
        email: userData['email']!,
      );
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des données.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
