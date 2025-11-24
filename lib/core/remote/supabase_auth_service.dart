import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

/// ================= Cloud Quiz Models =================
/// 列表页用到的简单信息
class CloudQuizSummary {
  final String id;          // cloud_quizzes.id
  final String title;       // cloud_quizzes.title
  /// 注意：这里字段名仍叫 ownerKey，但实际映射的是表里的 owner_id（uuid）
  final String ownerKey;    // cloud_quizzes.owner_id
  final DateTime createdAt; // cloud_quizzes.created_at
  final String shareCode;   // cloud_quizzes.share_code（分享码）

  CloudQuizSummary({
    required this.id,
    required this.title,
    required this.ownerKey,
    required this.createdAt,
    required this.shareCode,
  });

  factory CloudQuizSummary.fromMap(Map<String, dynamic> map) {
    return CloudQuizSummary(
      id: map['id'] as String,
      title: (map['title'] ?? '') as String,
      // Supabase 表里现在是 owner_id，没有 owner_key
      ownerKey: (map['owner_id'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      shareCode: (map['share_code'] ?? '') as String,
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
  // 上传 Quiz 到云端
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

      final questionInsert = {
        'quiz_id': quizId,
        'order_index': orderIndex,
        'question_type': q['question_type'],
        'number_of_options': q['number_of_options'],
        'content': q['content'],
        'correct_answer_ids': q['correct_answer_ids'],
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

    final list = (rows as List)
        .map((row) => CloudQuizSummary.fromMap(row as Map<String, dynamic>))
        .toList();

    return list;
  }

  // =========================================================
  // 从云端导入 Quiz 到本地
  // =========================================================
  Future<void> importQuizFromCloud({
    required String shareCode,
    required QuizDao quizDao,
  }) async {
    final ownerKey = currentUserEmail;
    if (ownerKey == null) {
      throw Exception('Please login first.');
    }

    // 1. 用 share_code 找到云端 quiz
    final cloudQuiz = await _client
        .from('cloud_quizzes')
        .select()
        .eq('share_code', shareCode) // 用分享码，不是 id
        .maybeSingle();

    if (cloudQuiz == null) {
      throw Exception('Quiz not found.');
    }

    final cloudQuizId = cloudQuiz['id'] as String;

    // 2. 取云端 questions
    final cloudQuestions = await _client
        .from('cloud_questions')
        .select()
        .eq('quiz_id', cloudQuizId) as List;

    // 3. 取云端 options（先拿所有 question_id）
    final questionIds =
    cloudQuestions.map((q) => q['id'] as String).toList();

    final cloudOptions = await _client
        .from('cloud_options')
        .select()
        .inFilter('question_id', questionIds) as List;

    // ======================
    // 转成本地结构
    // ======================
    final newQuizId = const Uuid().v4();
    final nowTs = DateTime.now().millisecondsSinceEpoch;

    // 构造本地 Quiz（对照 QuizzesCompanion.insert 的签名）
    final newQuiz = QuizzesCompanion.insert(
      id: newQuizId,
      title: (cloudQuiz['title'] as String?) ?? '',
      description: Value((cloudQuiz['description'] as String?) ?? ''),
      optionType: Value((cloudQuiz['option_type'] as int?) ?? 0),
      // 云端 pass_rate 是 smallint，本地是 int，这里转成 int
      passRate: Value((cloudQuiz['pass_rate'] as num?)?.toInt() ?? 60),
      enableScores: Value(cloudQuiz['enable_scores'] as bool? ?? false),
      createdAt: nowTs,
      updatedAt: nowTs,
      ownerKey: ownerKey,
    );

    // old → new question id 映射
    final Map<String, String> qidMap = {};

    // build local questions
    final localQuestions =
    cloudQuestions.map<QuestionsCompanion>((q) {
      final oldId = q['id'] as String;
      final newId = const Uuid().v4();
      qidMap[oldId] = newId;

      return QuestionsCompanion.insert(
        id: newId,
        quizId: newQuizId,
        orderIndex: q['order_index'] as int,
        questionType: Value(q['question_type'] as int? ?? 0),
        numberOfOptions: Value(q['number_of_options'] as int? ?? 4),
        content: (q['content'] as String?) ?? '',
        correctAnswerIds:
        Value(q['correct_answer_ids'] as String? ?? '[]'),
        score: Value(q['score'] as int? ?? 1),
      );
    }).toList();

    // build local options
    final localOptions =
    cloudOptions.map<QuizOptionsCompanion>((o) {
      final oldQid = o['question_id'] as String;
      final newQid = qidMap[oldQid]!;
      final newOptId = const Uuid().v4();

      return QuizOptionsCompanion.insert(
        id: newOptId,
        questionId: newQid,
        textValue: (o['text_value'] as String?) ?? '',
        orderIndex: o['order_index'] as int? ?? 0,
      );
    }).toList();

    // 5. 通过 QuizDao 一次性写入本地
    final bundle = QuizBundle(
      quiz: newQuiz,
      questions: localQuestions,
      options: localOptions,
    );

    await quizDao.saveBundle(bundle, ownerKey);
  }
}