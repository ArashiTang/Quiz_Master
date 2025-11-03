import 'package:drift/drift.dart';
import '../db/app_db.dart';
import '../db/tables/quizzes.dart';
import '../db/tables/questions.dart';
import '../db/tables/quiz_options.dart';

part 'quiz_dao.g.dart';

@DriftAccessor(tables: [Quizzes, Questions, QuizOptions])
class QuizDao extends DatabaseAccessor<AppDb> with _$QuizDaoMixin {
  QuizDao(AppDb db) : super(db);

  // ---- 基础查询 ----
  Future<List<Quizze>> getAllQuizzes() =>
      (select(quizzes)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

  Stream<List<Quizze>> watchAllQuizzes() =>
      (select(quizzes)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  Future<Quizze?> getQuiz(String id) =>
      (select(quizzes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Question>> getQuestionsByQuiz(String quizId) =>
      (select(questions)
        ..where((t) => t.quizId.equals(quizId))
        ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  Future<List<QuizOption>> getOptionsByQuestion(String questionId) =>
      (select(quizOptions)
        ..where((t) => t.questionId.equals(questionId))
        ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  // ---- 新增：获取单题 ----
  Future<Question?> getQuestion(String id) =>
      (select(questions)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---- 新增：统计某个 Quiz 的题目数量 ----
  Future<int> countQuestionsForQuiz(String quizId) async =>
      (select(questions)..where((t) => t.quizId.equals(quizId)))
          .get()
          .then((rows) => rows.length);

  // ---- 新增：删除单题（会自动级联删 options）----
  Future<void> deleteQuestionCascade(String questionId) async =>
      (delete(questions)..where((t) => t.id.equals(questionId))).go();

  // ---- 删除 Quiz（级联） ----
  Future<void> deleteQuizCascade(String quizId) async {
    await (delete(quizzes)..where((t) => t.id.equals(quizId))).go();
    // 外键 ON DELETE CASCADE 会自动清掉子表
  }

  // ---- Upsert 单条 ----
  Future<void> upsertQuiz(QuizzesCompanion data) async =>
      into(quizzes).insertOnConflictUpdate(data);

  Future<void> upsertQuestion(QuestionsCompanion data) async =>
      into(questions).insertOnConflictUpdate(data);

  Future<void> upsertOption(QuizOptionsCompanion data) async =>
      into(quizOptions).insertOnConflictUpdate(data);

  // ---- 打包保存：Quiz + Questions + Options（事务）----
  Future<void> saveBundle(QuizBundle bundle) async {
    await transaction(() async {
      await into(quizzes).insertOnConflictUpdate(bundle.quiz);

      // 先清理该 edit_and_list_quiz 下已有 questions（会级联删 options）
      await (delete(questions)
        ..where((t) => t.quizId.equals(bundle.quiz.id.value)))
          .go();

      // 重新插入
      for (final q in bundle.questions) {
        await into(questions).insert(q);
      }
      for (final o in bundle.options) {
        await into(quizOptions).insert(o);
      }
    });
  }
}

// ---- 传输模型（Bundle）----
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
