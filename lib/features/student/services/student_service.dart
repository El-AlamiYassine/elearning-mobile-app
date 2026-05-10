import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/course_model.dart';
import '../models/student_profile.dart';

class StudentService {
  final ApiService _apiService = ApiService();

  Future<List<CourseModel>> getEnrolledCourses() async {
    try {
      // Assuming endpoint is /student/courses or /courses/enrolled
      Response response = await _apiService.dio.get('/student/courses');
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => CourseModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }
}
