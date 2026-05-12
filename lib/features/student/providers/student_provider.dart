import 'dart:core';
import 'package:elearning/features/student/models/Category.dart';
import 'package:elearning/features/student/models/CourseProgress.dart';
import 'package:elearning/features/student/models/Course.dart';
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
  List<Category> categories = [];
  List<Course> allCourses = [];

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

  Future<List<CourseProgress>> fetchCourses() async {
    try {
      // Charger les données si elles ne sont pas encore disponibles
      if (dashboardData == null) {
        await fetchDashboardData();
      }

      return dashboardData?.courseProgressList ?? [];
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des cours.';
      notifyListeners();
      return [];
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      print('Fetching categories...');

      categories = await _studentService.getCategories();

      print('Categories fetched: $categories');
    } catch (e) {
      errorMessage =
          'Erreur lors du chargement des catégories.';
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> fetchAllCourses({int? categoryId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      allCourses = await _studentService.getAllCourses(
        categoryId: categoryId,
      );
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des cours.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
