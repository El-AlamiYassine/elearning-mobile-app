class CourseProgress {
    final int id;
    final String title;
    final String instructorName;
    final String imageUrl;
    final int progressPercentage;
    final int completedLessons;
    final int totalLessons;
  CourseProgress({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.imageUrl,
    required this.progressPercentage,
    required this.completedLessons,
    required this.totalLessons,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      instructorName: json['instructorName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      progressPercentage: json['progressPercentage'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
    );
  }
}