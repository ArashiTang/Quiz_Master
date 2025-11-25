import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_db.dart';
import '../db/tables/practice_runs.dart';
import '../db/tables/practice_answers.dart';
import '../utils/ids.dart';

part 'practice_dao.g.dart';

@DriftAccessor(tables: [PracticeRuns, PracticeAnswers])
class PracticeDao extends DatabaseAccessor<AppDb> with _$PracticeDaoMixin {
  PracticeDao(AppDb db) : super(db);

  // ===== Run list: Filtered by ownerKey =====

  Future<List<PracticeRun>> getRunsByOwner(String ownerKey) {
    return (select(practiceRuns)
      ..where((t) => t.ownerKey.equals(ownerKey))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Stream<List<PracticeRun>> watchRunsByOwner(String ownerKey) {
    return (select(practiceRuns)
      ..where((t) => t.ownerKey.equals(ownerKey))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  // ===== Start / End a practice session =====

  /// Let's start an exercise: Force the sending of the ownerKey ('Guest' or email address).
  Future<String> startRun(
      String quizId,
      String ownerKey, {
        int? startedAtMs,
      }) async {
    final id = newId('run');
    await into(practiceRuns).insert(
      PracticeRunsCompanion(
        id: Value(id),
        quizId: Value(quizId),
        ownerKey: Value(ownerKey),
        startedAt: Value(startedAtMs ?? nowMs()),
      ),
    );
    return id;
  }

  /// Submission call: Write end time and total score
  Future<void> finishRun(
      String runId,
      int score, {
        int? endedAtMs,
      }) async {
    await (update(practiceRuns)..where((t) => t.id.equals(runId))).write(
      PracticeRunsCompanion(
        endedAt: Value(endedAtMs ?? nowMs()),
        score: Value(score),
      ),
    );
  }

  // ===== Answer: Update if it exists / Insert if it doesn't exist. =====

  /// Internal unified method: Upsert an answer based on (runId, questionId)
  Future<void> upsertAnswer({
    required String runId,
    required String questionId,
    required Set<String> chosenIds,
    required bool isCorrect,
  }) async {
    // Check for old records
    final existing = await (select(practiceAnswers)
      ..where((t) =>
      t.runId.equals(runId) & t.questionId.equals(questionId)))
        .getSingleOrNull();

    final chosenJson = jsonEncode(chosenIds.toList());
    final ts = nowMs();

    if (existing == null) {
      // insert
      await into(practiceAnswers).insert(
        PracticeAnswersCompanion(
          id: Value(newId('ans')),
          runId: Value(runId),
          questionId: Value(questionId),
          chosenOptions: Value(chosenJson),
          isCorrect: Value(isCorrect),
          answeredAt: Value(ts),
        ),
      );
    } else {
      // renew
      await (update(practiceAnswers)..where((t) => t.id.equals(existing.id)))
          .write(
        PracticeAnswersCompanion(
          chosenOptions: Value(chosenJson),
          isCorrect: Value(isCorrect),
          answeredAt: Value(ts),
        ),
      );
    }
  }

  Future<void> saveAnswer({
    required String runId,
    required String questionId,
    required List<String> chosenIds,
    required bool correct,
  }) async {
    await upsertAnswer(
      runId: runId,
      questionId: questionId,
      chosenIds: chosenIds.toSet(),
      isCorrect: correct,
    );
  }

  // ===== Read all answers for the specified run. =====

  Future<List<PracticeAnswer>> getAnswersByRun(String runId) {
    return (select(practiceAnswers)
      ..where((t) => t.runId.equals(runId))
      ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
        .get();
  }

  Stream<List<PracticeAnswer>> watchAnswersByRun(String runId) {
    return (select(practiceAnswers)
      ..where((t) => t.runId.equals(runId))
      ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
        .watch();
  }

  // ===== Delete the entire session (including answers). =====

  Future<void> deleteRunCascade(String runId) async {
    await (delete(practiceAnswers)..where((t) => t.runId.equals(runId))).go();
    await (delete(practiceRuns)..where((t) => t.id.equals(runId))).go();
  }

  Future<PracticeRun?> getRunById(String runId) {
    return (select(practiceRuns)..where((t) => t.id.equals(runId)))
        .getSingleOrNull();
  }
}