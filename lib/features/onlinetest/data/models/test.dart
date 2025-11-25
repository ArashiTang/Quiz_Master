class Test {
  final String id;
  final String shareCode;
  final String title;
  final String quizId;
  final int timeLimit;
  final bool allowEntry;
  final String createdByEmail;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;

  Test({
    required this.id,
    required this.shareCode,
    required this.title,
    required this.quizId,
    required this.timeLimit,
    required this.allowEntry,
    required this.createdByEmail,
    required this.createdAt,
    this.startAt,
    this.endAt,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] as String,
      shareCode: json['share_code'] as String,
      title: (json['title'] ?? '') as String,
      quizId: json['quiz_id'] as String,
      timeLimit: (json['time_limit'] ?? 0) as int,
      allowEntry: (json['allow_entry'] ?? true) as bool,
      createdByEmail: (json['created_by_email'] ?? '') as String,
      startAt:
      json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'share_code': shareCode,
      'title': title,
      'quiz_id': quizId,
      'time_limit': timeLimit,
      'allow_entry': allowEntry,
      'created_by_email': createdByEmail,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}