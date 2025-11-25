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

  // ===== Quiz list: Filter by owner =====
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

  // ===== Single Quiz / Question / Options =====

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

  // Current number of quizzes
  Future<int> countQuestionsForQuiz(String quizId) async {
    final rows = await (select(questions)..where((t) => t.quizId.equals(quizId)))
        .get();
    return rows.length;
  }

  // ===== Delete (cascade) =====

  /// Delete the entire quiz; use `ON DELETE CASCADE` to clean up questions and options related to foreign keys.
  Future<void> deleteQuizCascade(String quizId) async {
    await (delete(quizzes)..where((t) => t.id.equals(quizId))).go();
  }

  /// Delete one question (and all its options).
  Future<void> deleteQuestionCascade(String questionId) async {
    // Delete options first
    await (delete(quizOptions)..where((t) => t.questionId.equals(questionId)))
        .go();
    // Delete the question again
    await (delete(questions)..where((t) => t.id.equals(questionId))).go();
  }

  // ===== Upsert: Force ownerKey =====

  /// Save/Update Quiz: Force write to ownerKey to prevent the caller from omitting the owner key.
  Future<void> upsertQuiz(QuizzesCompanion data, String ownerKey) async {
    final fixed = data.copyWith(
      ownerKey: Value(ownerKey),
    );
    await into(quizzes).insertOnConflictUpdate(fixed);
  }

  Future<void> upsertQuestion(QuestionsCompanion data) async {
    await into(questions).insertOnConflictUpdate(data);
  }

  Future<void> upsertOption(QuizOptionsCompanion data) async {
    await into(quizOptions).insertOnConflictUpdate(data);
  }

  // ===== Package and save: Quiz + Questions + Options (within a transaction, mandatory ownerKey) =====

  Future<void> saveBundle(QuizBundle bundle, String ownerKey) async {
    await transaction(() async {
      // 1) First save quiz (force ownerKey)
      final quizFixed = bundle.quiz.copyWith(
        ownerKey: Value(ownerKey),
      );
      await into(quizzes).insertOnConflictUpdate(quizFixed);

      // 2) Clean up the existing questions and options (belonging to this quiz).
      final quizId = quizFixed.id.value;
      final oldQuestions = await (select(questions)
        ..where((t) => t.quizId.equals(quizId)))
          .get();
      final oldQIds = oldQuestions.map((q) => q.id).toList();

      if (oldQIds.isNotEmpty) {
        // Delete options first
        await (delete(quizOptions)
          ..where((t) => t.questionId.isIn(oldQIds)))
            .go();
        // Delete questions again
        await (delete(questions)..where((t) => t.quizId.equals(quizId))).go();
      }

      // 3) Reinsert new questions and options
      for (final q in bundle.questions) {
        await into(questions).insert(q);
      }

      for (final o in bundle.options) {
        await into(quizOptions).insert(o);
      }
    });
  }
}

/// Packaged Quiz + Questions + Options for saving the entire QuizEditor application.
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