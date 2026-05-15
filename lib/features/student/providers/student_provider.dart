import 'dart:core';
import 'package:elearning/features/models/Lesson.dart';
import 'package:elearning/features/student/models/Category.dart';
import 'package:elearning/features/student/models/CourseProgress.dart';
import 'package:elearning/features/student/models/Course.dart';
import 'package:flutter/material.dart';
import '../models/StudentSummary.dart';
import '../models/student_profile.dart';
import '../services/student_service.dart';
import '../../../core/services/storage_service.dart';
import '../../models/Certificate.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  StudentProfile? profile;
  StudentSummary? dashboardData;
  bool isLoading = false;
  String? errorMessage;
  List<Category> categories = [];
  List<Course> allCourses = [];
  List<Certificate> certificates = [];

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
      errorMessage = 'Erreur lors du chargement des catégories.';
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

      allCourses = await _studentService.getAllCourses(categoryId: categoryId);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des cours.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCertificates() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      certificates = await _studentService.getCertificates();
      print('Certificates fetched: $certificates');
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des certificats.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Lesson>> fetchLessonsByCourse(int courseId) async {
    try {
      return await _studentService.getLessonsByCourse(courseId);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des leçons.';
      notifyListeners();
      return [];
    }
  }

  Future<Lesson?> fetchLessonDetails(int lessonId) async {
    try {
      return await _studentService.getLessonDetails(lessonId);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des détails de la leçon.';
      notifyListeners();
      return null;
    }
  }

  Future<void> markLessonCompleted(int lessonId) async {
    try {
      await _studentService.markLessonCompleted(lessonId);
      // Optionally, refresh the course progress or lesson details
      await fetchDashboardData();
    } catch (e) {
      errorMessage = 'Erreur lors de la mise à jour de la leçon.';
      notifyListeners();
    }
  }
}
