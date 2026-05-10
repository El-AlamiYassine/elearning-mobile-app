class CourseModel {
  final int id;
  final String title;
  final String description;
  final String? instructorName;
  final int duration; // in minutes
  final String? thumbnailUrl;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.instructorName,
    required this.duration,
    this.thumbnailUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['titre'] ?? 'Sans titre',
      description: json['description'] ?? '',
      instructorName: json['instructorName'] ?? json['enseignant'] ?? 'Inconnu',
      duration: json['duration'] ?? json['duree'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'] ?? json['image'],
    );
  }
}
