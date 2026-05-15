class Progress {
  final int? id;
  final bool termine;
  final DateTime dateMaj;

  final int etudiantId;
  final int lessonId;

  var completed;

  Progress({
    this.id,
    this.termine = false,
    DateTime? dateMaj,
    required this.etudiantId,
    required this.lessonId,
  }) : dateMaj = dateMaj ?? DateTime.now();

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      termine: json['termine'] ?? false,
      dateMaj: json['dateMaj'] != null
          ? DateTime.parse(json['dateMaj'])
          : DateTime.now(),

      etudiantId: json['etudiant'] != null
          ? json['etudiant']['id']
          : json['etudiantId'],

      lessonId: json['lesson'] != null
          ? json['lesson']['id']
          : json['lessonId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'termine': termine,
      'dateMaj': dateMaj.toIso8601String(),
      'etudiantId': etudiantId,
      'lessonId': lessonId,
    };
  }
}