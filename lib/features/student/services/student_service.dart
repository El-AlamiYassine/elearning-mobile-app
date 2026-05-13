import 'dart:core';
import 'package:dio/dio.dart';
import 'package:elearning/features/models/Certificate.dart';
import 'package:elearning/features/student/models/Category.dart';
import '../../../core/services/api_service.dart';
import '../models/StudentSummary.dart';
// ignore: unused_import
import '../models/Course.dart';
// ignore: duplicate_import
import '../models/Category.dart';

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
        queryParameters: categoryId != null
            ? {'categoryId': categoryId}
            : null,
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
}
