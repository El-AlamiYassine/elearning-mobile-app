import 'CourseProgress.dart';

class StudentSummary {
  final int enrolledCoursesCount;
  final int completedCoursesCount;
  final int averageAttendance;
  final List<CourseProgress> courseProgressList;

  StudentSummary({
    required this.enrolledCoursesCount,
    required this.completedCoursesCount,
    required this.averageAttendance,
    required this.courseProgressList,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      enrolledCoursesCount: json['enrolledCoursesCount'] ?? 0,
      completedCoursesCount: json['completedCoursesCount'] ?? 0,
      averageAttendance: json['averageAttendance'] ?? 0,

      courseProgressList: (json['recentCourses'] as List<dynamic>?)
              ?.map((e) =>
                  CourseProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}