import 'package:drift/drift.dart';

import '../db/app_db.dart';
import '../db/tables/quizzes.dart';
import '../db/tables/questions.dart';
import '../db/tables/quiz_options.dart';
import '../utils/ids.dart';

part 'quiz_dao.g.dart';

@DriftAccessor(tables: [Quizzes, Questions, QuizOptions])
class QuizDao extends DatabaseAccessor<AppDb> with _$QuizDaoMixin {
  QuizDao(AppDb db) : super(db);

  // ===== Quiz 列表：按 owner 过滤 =====
  Future<List<Quizze>> getQuizzesByOwner(String ownerKey) {
    return (select(quizzes)
      ..where((t) => t.ownerKey.equals(ownerKey))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Stream<List<Quizze>> watchQuizzesByOwner(String ownerKey) {
    return (select(quizzes)
      ..where((t) => t.ownerKey.equals(ownerKey))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  // ===== 单个 Quiz / 题目 / 选项 =====

  Future<Quizze?> getQuizById(String id) {
    return (select(quizzes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Question>> getQuestionsByQuiz(String quizId) {
    return (select(questions)
      ..where((t) => t.quizId.equals(quizId))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Future<Question?> getQuestionById(String questionId) {
    return (select(questions)..where((t) => t.id.equals(questionId)))
        .getSingleOrNull();
  }

  Future<List<QuizOption>> getOptionsByQuestion(String questionId) {
    return (select(quizOptions)
      ..where((t) => t.questionId.equals(questionId))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  // 当前 quiz 下有多少题
  Future<int> countQuestionsForQuiz(String quizId) async {
    final rows = await (select(questions)..where((t) => t.quizId.equals(quizId)))
        .get();
    return rows.length;
  }

  // ===== 删除（级联） =====

  /// 删一整份 quiz；依赖外键 ON DELETE CASCADE 清理 questions & options
  Future<void> deleteQuizCascade(String quizId) async {
    await (delete(quizzes)..where((t) => t.id.equals(quizId))).go();
  }

  /// 删一题（和它的所有选项）
  Future<void> deleteQuestionCascade(String questionId) async {
    // 先删 options
    await (delete(quizOptions)..where((t) => t.questionId.equals(questionId)))
        .go();
    // 再删 question
    await (delete(questions)..where((t) => t.id.equals(questionId))).go();
  }

  // ===== Upsert：强制 ownerKey =====

  /// 保存/更新 Quiz：强制写入 ownerKey，避免调用方漏传 owner
  Future<void> upsertQuiz(QuizzesCompanion data, String ownerKey) async {
    final fixed = data.copyWith(
      ownerKey: Value(ownerKey),
      // 如果调用方忘记填 createdAt / updatedAt，你也可以在这里兜底：
      // createdAt: data.createdAt.present
      //     ? data.createdAt
      //     : Value(nowMs()),
      // updatedAt: Value(nowMs()),
    );
    await into(quizzes).insertOnConflictUpdate(fixed);
  }

  Future<void> upsertQuestion(QuestionsCompanion data) async {
    await into(questions).insertOnConflictUpdate(data);
  }

  Future<void> upsertOption(QuizOptionsCompanion data) async {
    await into(quizOptions).insertOnConflictUpdate(data);
  }

  // ===== 打包保存：Quiz + Questions + Options（事务内，强制 ownerKey） =====

  Future<void> saveBundle(QuizBundle bundle, String ownerKey) async {
    await transaction(() async {
      // 1) 先保存 quiz（强制 ownerKey）
      final quizFixed = bundle.quiz.copyWith(
        ownerKey: Value(ownerKey),
      );
      await into(quizzes).insertOnConflictUpdate(quizFixed);

      // 2) 清理原有题目及选项（属于这个 quiz）
      final quizId = quizFixed.id.value;
      final oldQuestions = await (select(questions)
        ..where((t) => t.quizId.equals(quizId)))
          .get();
      final oldQIds = oldQuestions.map((q) => q.id).toList();

      if (oldQIds.isNotEmpty) {
        // 先删 options
        await (delete(quizOptions)
          ..where((t) => t.questionId.isIn(oldQIds)))
            .go();
        // 再删 questions
        await (delete(questions)..where((t) => t.quizId.equals(quizId))).go();
      }

      // 3) 重新插入新的 questions & options
      for (final q in bundle.questions) {
        await into(questions).insert(q);
      }

      for (final o in bundle.options) {
        await into(quizOptions).insert(o);
      }
    });
  }
}

/// 打包后的 Quiz + Questions + Options，用于 QuizEditor 整体保存
class QuizBundle {
  final QuizzesCompanion quiz;
  final List<QuestionsCompanion> questions;
  final List<QuizOptionsCompanion> options;

  QuizBundle({
    required this.quiz,
    required this.questions,
    required this.options,
  });
}