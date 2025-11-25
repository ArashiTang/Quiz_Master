class TestResult {
  final int id;
  final String testId;
  final String userName;
  final String userEmail;
  final double scorePercent;
  final String result;
  final DateTime submittedAt;
  final String? localRecordId;

  TestResult({
    required this.id,
    required this.testId,
    required this.userName,
    required this.userEmail,
    required this.scorePercent,
    required this.result,
    required this.submittedAt,
    this.localRecordId,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: (json['id'] as num).toInt(),
      testId: json['test_id'] as String,
      userName: (json['user_name'] ?? '') as String,
      userEmail: (json['user_email'] ?? '') as String,
      scorePercent: double.parse((json['score_percent']).toString()),
      result: json['result'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      localRecordId: json['local_record_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_id': testId,
      'user_name': userName,
      'user_email': userEmail,
      'score_percent': scorePercent,
      'result': result,
      'submitted_at': submittedAt.toIso8601String(),
      'local_record_id': localRecordId,
    };
  }
}