import 'package:flutter/material.dart';
import '../models/StudentSummary.dart';
import '../models/student_profile.dart';
import '../services/student_service.dart';
import '../../../core/services/storage_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  StudentProfile? profile;
  StudentSummary? dashboardData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch both profile and courses in parallel if possible, or sequentially
      final userData = await StorageService().getUserData();
      final dashboardData = await _studentService.getDashboardSummary();
      profile = StudentProfile.fromJson(userData);
      this.dashboardData = dashboardData;

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
