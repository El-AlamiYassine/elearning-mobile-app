import 'Document.dart';
import 'Quiz.dart';
import 'Progress.dart';

class Lesson {
  final int? id;
  final String titre;
  final String? contenu;
  final String? videoUrl;
  final int ordre;

  final int? courseId;

  final List<Document>? documents;
  final Quiz? quiz;
  final List<Progress>? progresses;

  // extra backend fields
  final bool completed;
  final bool hasQuiz;
  final int? quizId;

  Lesson({
    this.id,
    required this.titre,
    this.contenu,
    this.videoUrl,
    this.ordre = 1,
    this.courseId,
    this.documents,
    this.quiz,
    this.progresses,
    this.completed = false,
    this.hasQuiz = false,
    this.quizId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],

      // ✅ backend uses title
      titre: json['title'] ?? '',

      // ✅ backend uses content
      contenu: json['content'],

      videoUrl: json['videoUrl'],

      ordre: json['ordre'] ?? 1,

      courseId: json['courseId'],

      completed: json['completed'] ?? false,

      hasQuiz: json['hasQuiz'] ?? false,

      quizId: json['quizId'],

      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((e) => Document.fromJson(e))
              .toList()
          : null,

      quiz: json['quiz'] != null
          ? Quiz.fromJson(json['quiz'])
          : null,

      progresses: json['progresses'] != null
          ? (json['progresses'] as List)
              .map((e) => Progress.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titre,
      'content': contenu,
      'videoUrl': videoUrl,
      'ordre': ordre,
      'courseId': courseId,
    };
  }
}