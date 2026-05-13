import 'Document.dart';
import 'Quiz.dart';
import 'Progress.dart';
class Lesson {
  final int? id;
  final String titre;
  final String? contenu;
  final String? videoUrl;
  final int ordre;

  final int courseId;

  final List<Document>? documents;
  final Quiz? quiz;
  final List<Progress>? progresses;

  Lesson({
    this.id,
    required this.titre,
    this.contenu,
    this.videoUrl,
    this.ordre = 1,
    required this.courseId,
    this.documents,
    this.quiz,
    this.progresses,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      videoUrl: json['videoUrl'],
      ordre: json['ordre'] ?? 1,

      // backend: cours object → on récupère juste l'id
      courseId: json['cours'] != null ? json['cours']['id'] : json['courseId'],

      // relations souvent ignorées ou chargées séparément
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((e) => Document.fromJson(e))
              .toList()
          : null,

      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,

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
      'titre': titre,
      'contenu': contenu,
      'videoUrl': videoUrl,
      'ordre': ordre,
      'courseId': courseId,
    };
  }
}