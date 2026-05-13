class Question {
  final int? id;
  final String enonce;

  final String optionA;
  final String optionB;
  final String? optionC;
  final String? optionD;

  final String reponseCorrecte;

  // relation simplifiée
  final int? quizId;

  Question({
    this.id,
    required this.enonce,
    required this.optionA,
    required this.optionB,
    this.optionC,
    this.optionD,
    required this.reponseCorrecte,
    this.quizId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      enonce: json['enonce'] ?? '',

      optionA: json['optionA'] ?? '',
      optionB: json['optionB'] ?? '',
      optionC: json['optionC'],
      optionD: json['optionD'],

      reponseCorrecte: json['reponseCorrecte'] ?? '',

      // backend may send quiz object or id
      quizId: json['quiz'] != null
          ? json['quiz']['id']
          : json['quizId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enonce': enonce,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'reponseCorrecte': reponseCorrecte,

      // backend expects ID
      'quizId': quizId,
    };
  }
}