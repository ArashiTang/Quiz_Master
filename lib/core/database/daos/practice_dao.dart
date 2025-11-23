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

  // ===== 运行列表：按 ownerKey 过滤 =====

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

  // ===== 开始 / 结束一场练习 =====

  /// 开始一场练习：强制传 ownerKey（'Guest' 或邮箱）
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

  /// 提交时调用：写结束时间与总分
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

  // ===== 答题：有则更新 / 无则插入 =====

  /// 内部统一方法：基于 (runId, questionId) upsert 一条答案
  Future<void> upsertAnswer({
    required String runId,
    required String questionId,
    required Set<String> chosenIds,
    required bool isCorrect,
  }) async {
    // 查有没有旧记录
    final existing = await (select(practiceAnswers)
      ..where((t) =>
      t.runId.equals(runId) & t.questionId.equals(questionId)))
        .getSingleOrNull();

    final chosenJson = jsonEncode(chosenIds.toList());
    final ts = nowMs();

    if (existing == null) {
      // 插入
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
      // 更新
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

  /// 兼容你之前的调用：外部还在用 List<String> + correct
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

  // ===== 读取指定 run 的所有作答 =====

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

  // ===== 删除整场（含答案） =====

  Future<void> deleteRunCascade(String runId) async {
    await (delete(practiceAnswers)..where((t) => t.runId.equals(runId))).go();
    await (delete(practiceRuns)..where((t) => t.id.equals(runId))).go();
  }

  Future<PracticeRun?> getRunById(String runId) {
    return (select(practiceRuns)..where((t) => t.id.equals(runId)))
        .getSingleOrNull();
  }
}