import 'dart:core';
import 'package:dio/dio.dart';
import 'package:elearning/features/models/Certificate.dart';
import 'package:elearning/features/student/models/Category.dart';
import '../../../core/services/api_service.dart';
import '../models/StudentSummary.dart';
import '../models/Course.dart';
import '../../models/Lesson.dart';

class StudentService {
  final ApiService _apiService = ApiService();

  Future<StudentSummary> getDashboardSummary() async {
    try {
      // Assuming endpoint is /student/courses or /courses/enrolled
      Response response = await _apiService.dio.get(
        '/student/dashboard/summary',
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return StudentSummary.fromJson(data);
      }
      return StudentSummary.fromJson({});
    } catch (e) {
      print('Error fetching courses: $e');
      return StudentSummary.fromJson({});
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      Response response = await _apiService.dio.get('/student/categories');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        return data.map((json) => Category.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Course>> getAllCourses({int? categoryId}) async {
    try {
      final response = await _apiService.dio.get(
        '/student/catalog',
        queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
      );

      if (response.statusCode == 200) {
        final List data = response.data;

        return data.map((json) => Course.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<List<Certificate>> getCertificates() async {
    try {
      final response = await _apiService.dio.get('/student/certificates');

      if (response.statusCode == 200) {
        final List data = response.data;

        return data.map((json) => Certificate.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching certificates: $e');
      return [];
    }
  }

  Future<List<Lesson>> getLessonsByCourse(int courseId) async {
    try {
      final response = await _apiService.dio.get(
        '/student/courses/$courseId/lessons',
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        print('Lessons data: $data');
        return data.map((json) => Lesson.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  Future<Lesson?> getLessonDetails(int lessonId) async {
    try {
      final response = await _apiService.dio.get('/student/lessons/$lessonId');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Lesson details data:');
        return Lesson.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Error fetching lesson details: $e');
      return null;
    }
  }

  Future<bool> markLessonCompleted(int lessonId) async {
    try {
      final response = await _apiService.dio.post(
        '/student/lessons/$lessonId/complete',
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error marking lesson as completed: $e');
      return false;
    }
  }

  Future <bool> enrollInCourse(int courseId) async {
    try {
      final response = await _apiService.dio.post(
        '/student/courses/$courseId/enroll',
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }
}
