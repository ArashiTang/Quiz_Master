import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// ================= Cloud Quiz Models =================
/// 列表页用到的简单信息
class CloudQuizSummary {
  final String id;          // cloud_quizzes.id
  final String title;       // cloud_quizzes.title
  final String? description;
  final String ownerKey;    // cloud_quizzes.owner_id（或 owner_email）
  final DateTime createdAt; // cloud_quizzes.created_at
  final String shareCode;   // cloud_quizzes.share_code（分享码）

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

  /// 当前登录的 Supabase 用户（可能为 null）
  User? get currentUser => _client.auth.currentUser;

  /// 是否已登录
  bool get isLoggedIn => currentUser != null;

  /// 当前本地数据的 ownerKey：
  /// - 未登录：'Guest'
  /// - 已登录：用户邮箱
  String get currentOwnerKey {
    final user = currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return 'Guest';
    }
    return email;
  }

  /// 当前用户的 email，仍然用来当本地数据库的 ownerKey
  String? get currentUserEmail => currentUser?.email;
  String get ownerKey => currentUserEmail ?? 'Guest';

  // =========================================================
  // 登录
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
  // 注册（OTP）
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

    // 同步一份 profile 到 Supabase 表
    await _client.from('profiles').upsert({
      'id': user.id,
      'username': username,
    });

    return user;
  }

  // =========================================================
  // 重置密码（OTP）
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
  // 登出
  // =========================================================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =========================================================
  // 获取用户 profile 显示在 Mine
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

  /// 修改用户名（同时更新 auth.metadata 和 Supabase profiles 表）
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
  // 上传 Quiz 到云端（使用 correct_answer_texts）
  // =========================================================
  ///
  /// [quiz]：一个 map，对应 cloud_quizzes 的字段（不含 owner_id）
  /// [questions]：每个元素是 map，对应 cloud_questions 的字段（不含 quiz_id）
  /// [options]：每个元素是 map，对应 cloud_options 的字段，
  ///            其中必须包含 question_order_index，用来和 questions 对应。
  ///
  /// 返回 share_code，作为分享码。
  Future<String> uploadQuizToCloud({
    required Map<String, dynamic> quiz,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> options,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in before uploading quiz.');
    }

    // 注意：这里写入的是 owner_id（uuid），不是邮箱，也不是 owner_key
    final ownerId = user.id;

    // 1. 插入 cloud_quizzes
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

    // 2. 插入 cloud_questions，并把 Supabase 返回的 question.id 记下来
    //    key: order_index -> value: question_id
    final Map<int, String> questionIdByOrderIndex = {};

    for (final q in questions) {
      final orderIndex = q['order_index'] as int;

      // 关键：从 map 里取“正确答案文本 JSON”
      // 你在 QuizEditor 里构造 payload 时，只要填上 correct_answer_texts 或 correctAnswerTexts 即可
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

    // 3. 插入 cloud_options
    for (final o in options) {
      final questionOrderIndex = o['question_order_index'] as int;
      final questionId = questionIdByOrderIndex[questionOrderIndex];

      if (questionId == null) {
        // 理论上不会发生，只是防御性写法
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
  // Cloud 列表：获取当前用户在云端上传的所有 Quiz
  // =========================================================
  Future<List<CloudQuizSummary>> fetchMyCloudQuizList() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    // 这里同样按 owner_id（uuid）过滤，而不是邮箱
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
  // 从云端导入 Quiz 到本地（使用 correct_answer_texts）
  // =========================================================
  Future<String> importQuizFromCloud({
    required String shareCode,
    required QuizDao quizDao,
  }) async {
    final ownerKey = currentUserEmail;
    if (ownerKey == null) {
      throw Exception('Please login first.');
    }

    // 1. 用 shareCode（其实就是 quiz 的 id）找到云端 quiz
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

    // 2. 取 questions（已经是“正确答案文本”字段）
    final List<dynamic> cloudQuestions = await _client
        .from('cloud_questions')
        .select(
      'id, quiz_id, order_index, question_type, '
          'number_of_options, content, correct_answer_texts, score',
    )
        .eq('quiz_id', cloudQuizId);

    // 3. 取 options
    final List<dynamic> cloudOptions = await _client
        .from('cloud_options')
        .select('id, question_id, order_index, text_value')
        .inFilter(
      'question_id',
      cloudQuestions.map((q) => q['id'] as String).toList(),
    );

    // 按 question_id 把 options 分组
    final Map<String, List<Map<String, dynamic>>> optionsByQuestion = {};
    for (final o in cloudOptions) {
      final map = Map<String, dynamic>.from(o as Map);
      final qid = map['question_id'] as String;
      optionsByQuestion.putIfAbsent(qid, () => <Map<String, dynamic>>[]).add(map);
    }

    // ======================
    //       本地化处理
    // ======================

    final newQuizId = const Uuid().v4();
    final nowTs = DateTime.now().millisecondsSinceEpoch;

    // 本地 quiz
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

      // 该题目在云端的全部选项
      final optsForThisQuestion =
          optionsByQuestion[oldQid] ?? const <Map<String, dynamic>>[];

      // 先导入所有选项（生成新的本地 optionId）
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

      // 直接用云端存的 correct_answer_texts 写入本地字段 correctAnswerTexts
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