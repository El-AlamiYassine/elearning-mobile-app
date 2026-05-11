import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/StudentSummary.dart';

class StudentService {
  final ApiService _apiService = ApiService();

  Future<StudentSummary> getDashboardSummary() async {
    try {
      // Assuming endpoint is /student/courses or /courses/enrolled
      Response response = await _apiService.dio.get('/student/dashboard/summary');
      
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
}
