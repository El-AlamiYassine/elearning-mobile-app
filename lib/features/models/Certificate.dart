class Certificate {
  final int? id;
  final String studentName;
  final String courseTitle;
  final DateTime issueDate;
  final String verificationCode;

  Certificate({
    this.id,
    required this.studentName,
    required this.courseTitle,
    required this.issueDate,
    required this.verificationCode,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      studentName: json['studentName'] ?? '',
      courseTitle: json['courseTitle'] ?? '',

      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'])
          : DateTime.now(),

      verificationCode: json['verificationCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'courseTitle': courseTitle,
      'issueDate': issueDate.toIso8601String(),
      'verificationCode': verificationCode,
    };
  }
}