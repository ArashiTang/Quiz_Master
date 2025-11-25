import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// ================= Cloud Quiz Models =================
/// Simple information used on the list page
class CloudQuizSummary {
  final String id;          // cloud_quizzes.id
  final String title;       // cloud_quizzes.title
  final String? description;
  final String ownerKey;    // cloud_quizzes.owner_id（or owner_email）
  final DateTime createdAt; // cloud_quizzes.created_at
  final String shareCode;   // cloud_quizzes.share_code（share_code）

  CloudQuizSummary({
    required this.id,
    required this.title,
    this.description,
    required this.ownerKey,
    required this.createdAt,
    required this.shareCode,
  });

  factory CloudQuizSummary.fromMap(Map<String, dynamic> map) {
    return CloudQuizSummary(
      id: map['id'] as String,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      ownerKey: (map['owner_id'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      shareCode: (map['share_code'] ?? map['id'] ?? '') as String,
    );
  }
}

class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// The currently logged-in Supabase user (may be null)
  User? get currentUser => _client.auth.currentUser;

  /// Login or not
  bool get isLoggedIn => currentUser != null;

  /// The ownerKey of the current local data:
  /// - Not logged in: 'Guest'
  /// - Logged in: User email
  String get currentOwnerKey {
    final user = currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return 'Guest';
    }
    return email;
  }

  /// The current user's email address is still used as the ownerKey in the local database.
  String? get currentUserEmail => currentUser?.email;
  String get ownerKey => currentUserEmail ?? 'Guest';

  // =========================================================
  // Log in
  // =========================================================
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  // =========================================================
  // Registration (OTP)
  // =========================================================
  Future<void> sendSignupOtp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<User> verifySignupOtpAndCreateProfile({
    required String email,
    required String token,
    required String username,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );

    final user = res.user ?? _client.auth.currentUser;
    if (user == null) {
      throw Exception('OTP verified but user is null.');
    }

    // Synchronize a profile to a Supabase table
    await _client.from('profiles').upsert({
      'id': user.id,
      'username': username,
    });

    return user;
  }

  // =========================================================
  // Reset Password (OTP)
  // =========================================================
  Future<void> sendResetOtp({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyResetOtpAndSignIn({
    required String email,
    required String token,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );

    if (res.user == null && _client.auth.currentUser == null) {
      throw Exception('Password reset verification failed.');
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // =========================================================
  // Sign out
  // =========================================================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =========================================================
  // Get user profile and display it in Mine
  // =========================================================
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      return {
        'id': null,
        'email': 'Guest',
        'username': 'Guest',
      };
    }

    final meta = user.userMetadata ?? {};
    final name = (meta['username'] as String?)?.trim();

    return {
      'id': user.id,
      'email': user.email,
      'username': (name == null || name.isEmpty) ? 'Guest' : name,
    };
  }

  /// Modify the username (and update the auth.metadata and Supabase profiles tables simultaneously).
  Future<void> updateUsername(String newUsername) async {
    final user = currentUser;
    if (user == null) throw Exception('Not logged in');

    final n = newUsername.trim();
    if (n.isEmpty) throw Exception('Username cannot be empty.');

    await _client.auth.updateUser(
      UserAttributes(data: {'username': n}),
    );

    await _client.from('profiles').update({'username': n}).eq('id', user.id);
  }

  // =========================================================
  // Upload the quiz to the cloud (using correct_answer_texts).
  // =========================================================
  ///
  /// [quiz]：A map corresponding to the fields of cloud_quizzes (excluding owner_id).
  /// [questions]：Each element is a map, corresponding to a field in cloud_questions (excluding quiz_id).
  /// [options]：Each element is a map, corresponding to the field of cloud_options.
  ///            It must include question_order_index, which is used to correspond to questions.
  ///
  /// Returns share_code as the sharing code.
  Future<String> uploadQuizToCloud({
    required Map<String, dynamic> quiz,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> options,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in before uploading quiz.');
    }

    // Note: This is where you enter the owner_id (UUID), not the email address or owner_key.
    final ownerId = user.id;

    // 1. insert cloud_quizzes
    final quizInsert = {
      ...quiz,
      'owner_id': ownerId,
    };

    final insertedQuiz = await _client
        .from('cloud_quizzes')
        .insert(quizInsert)
        .select()
        .single();

    final quizId = insertedQuiz['id'] as String;
    final shareCode = (insertedQuiz['share_code'] ?? quizId).toString();

    // 2. Insert `cloud_questions` and record the `question.id` returned by Supabase.
    //    key: order_index -> value: question_id
    final Map<int, String> questionIdByOrderIndex = {};

    for (final q in questions) {
      final orderIndex = q['order_index'] as int;

      // Key: Retrieve the "correct answer text JSON" from the map.
      // When constructing the payload in QuizEditor, simply fill in either `correct_answer_texts` or `correctAnswerTexts`.
      final String correctAnswerTexts =
          (q['correct_answer_texts'] as String?) ??
              (q['correctAnswerTexts'] as String?) ??
              '[]';

      final questionInsert = {
        'quiz_id': quizId,
        'order_index': orderIndex,
        'question_type': q['question_type'],
        'number_of_options': q['number_of_options'],
        'content': q['content'],
        'correct_answer_texts': correctAnswerTexts,
        'score': q['score'],
      };

      final insertedQuestion = await _client
          .from('cloud_questions')
          .insert(questionInsert)
          .select()
          .single();

      final questionId = insertedQuestion['id'] as String;
      questionIdByOrderIndex[orderIndex] = questionId;
    }

    // 3. insert cloud_options
    for (final o in options) {
      final questionOrderIndex = o['question_order_index'] as int;
      final questionId = questionIdByOrderIndex[questionOrderIndex];

      if (questionId == null) {
        // Theoretically, this won't happen; it's just a defensive way of writing it.
        continue;
      }

      final optionInsert = {
        'question_id': questionId,
        'order_index': o['order_index'],
        'text_value': o['text_value'],
      };

      await _client.from('cloud_options').insert(optionInsert);
    }

    return shareCode;
  }

  // =========================================================
  // Cloud List: Retrieves all Quiz uploads made by the current user in the cloud.
  // =========================================================
  Future<List<CloudQuizSummary>> fetchMyCloudQuizList() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    // Here, we also filter by owner_id (UUID), not email.
    final ownerId = user.id;

    final rows = await _client
        .from('cloud_quizzes')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map((row) {
      final map = row as Map<String, dynamic>;
      return CloudQuizSummary(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        ownerKey: map['owner_id'] as String? ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
        shareCode: (map['share_code'] ?? map['id'] ?? '') as String,
      );
    }).toList();
  }

  // =========================================================
  // Import Quiz from the cloud to your local machine (using correct_answer_texts)
  // =========================================================
  Future<String> importQuizFromCloud({
    required String shareCode,
    required QuizDao quizDao,
  }) async {
    final ownerKey = currentUserEmail;
    if (ownerKey == null) {
      throw Exception('Please login first.');
    }

    // 1. Use the shareCode (which is actually the quiz ID) to find the cloud quiz.
    final cloudQuiz = await _client
        .from('cloud_quizzes')
        .select(
      'id, title, description, option_type, pass_rate, enable_scores',
    )
        .eq('id', shareCode)
        .maybeSingle();

    if (cloudQuiz == null) {
      throw Exception('Quiz not found.');
    }

    final cloudQuizId = cloudQuiz['id'] as String;

    // 2. Retrieve the questions field (which is already the "correct answer text" field).
    final List<dynamic> cloudQuestions = await _client
        .from('cloud_questions')
        .select(
      'id, quiz_id, order_index, question_type, '
          'number_of_options, content, correct_answer_texts, score',
    )
        .eq('quiz_id', cloudQuizId);

    // 3. Get options
    final List<dynamic> cloudOptions = await _client
        .from('cloud_options')
        .select('id, question_id, order_index, text_value')
        .inFilter(
      'question_id',
      cloudQuestions.map((q) => q['id'] as String).toList(),
    );

    // Group options by question_id
    final Map<String, List<Map<String, dynamic>>> optionsByQuestion = {};
    for (final o in cloudOptions) {
      final map = Map<String, dynamic>.from(o as Map);
      final qid = map['question_id'] as String;
      optionsByQuestion.putIfAbsent(qid, () => <Map<String, dynamic>>[]).add(map);
    }

    // ======================
    //       Localization
    // ======================

    final newQuizId = const Uuid().v4();
    final nowTs = DateTime.now().millisecondsSinceEpoch;

    // local quiz
    final quizCompanion = QuizzesCompanion.insert(
      id: newQuizId,
      title: cloudQuiz['title'] as String? ?? '',
      description: Value(cloudQuiz['description'] as String? ?? ''),
      optionType: Value(cloudQuiz['option_type'] as int? ?? 0),
      passRate: Value((cloudQuiz['pass_rate'] as num?)?.toInt() ?? 60),
      enableScores: Value(cloudQuiz['enable_scores'] as bool? ?? false),
      createdAt: nowTs,
      updatedAt: nowTs,
      ownerKey: ownerKey,
    );

    final List<QuestionsCompanion> localQuestions = [];
    final List<QuizOptionsCompanion> localOptions = [];

    for (final q in cloudQuestions) {
      final qMap = Map<String, dynamic>.from(q as Map);
      final oldQid = qMap['id'] as String;
      final newQid = const Uuid().v4();

      // All options for this question are available in the cloud.
      final optsForThisQuestion =
          optionsByQuestion[oldQid] ?? const <Map<String, dynamic>>[];

      // First, import all options (to generate a new local optionId).
      for (final o in optsForThisQuestion) {
        final oMap = Map<String, dynamic>.from(o);
        final text = oMap['text_value'] as String? ?? '';
        final orderIndex = oMap['order_index'] as int? ?? 0;
        final newOptId = const Uuid().v4();

        localOptions.add(
          QuizOptionsCompanion.insert(
            id: newOptId,
            questionId: newQid,
            textValue: text,
            orderIndex: orderIndex,
          ),
        );
      }

      // Write the correct_answer_texts stored in the cloud directly to the local field correctAnswerTexts.
      final String rawTexts =
          qMap['correct_answer_texts'] as String? ?? '[]';

      localQuestions.add(
        QuestionsCompanion.insert(
          id: newQid,
          quizId: newQuizId,
          orderIndex: qMap['order_index'] as int? ?? 0,
          questionType: Value(qMap['question_type'] as int? ?? 0),
          numberOfOptions: Value(qMap['number_of_options'] as int? ?? 4),
          content: qMap['content'] as String? ?? '',
          correctAnswerTexts: Value(rawTexts),
          score: Value(qMap['score'] as int? ?? 1),
        ),
      );
    }

    final bundle = QuizBundle(
      quiz: quizCompanion,
      questions: localQuestions,
      options: localOptions,
    );

    await quizDao.saveBundle(bundle, ownerKey);

    return newQuizId;
  }
}