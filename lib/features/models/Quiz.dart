import 'Question.dart';
class Quiz {
  final int? id;
  final String titre;
  final int dureeMinutes;
  final int scoreMinimum;

  // relations simplifiées
  final int? lessonId;
  final int? courseId;

  final List<Question>? questions;

  Quiz({
    this.id,
    required this.titre,
    this.dureeMinutes = 30,
    this.scoreMinimum = 50,
    this.lessonId,
    this.courseId,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      titre: json['titre'] ?? '',

      dureeMinutes: json['dureeMinutes'] ?? 30,
      scoreMinimum: json['scoreMinimum'] ?? 50,

      // backend may send object or id → handle both
      lessonId: json['lesson'] != null
          ? json['lesson']['id']
          : json['lessonId'],

      courseId: json['cours'] != null
          ? json['cours']['id']
          : json['courseId'],

      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((e) => Question.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'dureeMinutes': dureeMinutes,
      'scoreMinimum': scoreMinimum,

      // backend expects IDs (not full objects)
      'lessonId': lessonId,
      'courseId': courseId,
    };
  }
}