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

  // ===== 运行列表 =====
  Stream<List<PracticeRun>> watchRuns() =>
      (select(practiceRuns)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  Future<List<PracticeRun>> getRuns() =>
      (select(practiceRuns)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  // ===== 开始/结束一场 =====
  Future<String> startRun(String quizId) async {
    final id = newId('run');
    await into(practiceRuns).insert(
      PracticeRunsCompanion(
        id: Value(id),
        quizId: Value(quizId),
        startedAt: Value(nowMs()),
      ),
    );
    return id;
  }

  /// 提交时调用：写结束时间与总分
  Future<void> finishRun(String runId, int score) async {
    await (update(practiceRuns)..where((t) => t.id.equals(runId))).write(
      PracticeRunsCompanion(
        endedAt: Value(nowMs()),
        score: Value(score),
      ),
    );
  }

  // ===== 作答（有则更/无则增） =====
  /// 推荐使用：基于 (runId, questionId) “查一条，有则更新，无则插入”
  Future<void> upsertAnswer({
    required String runId,
    required String questionId,
    required Set<String> chosenIds,
    required bool isCorrect,
  }) async {
    // 查有没有旧记录
    final existing = await (select(practiceAnswers)
      ..where((t) => t.runId.equals(runId) & t.questionId.equals(questionId)))
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
      await (update(practiceAnswers)
        ..where((t) => t.id.equals(existing.id)))
          .write(
        PracticeAnswersCompanion(
          chosenOptions: Value(chosenJson),
          isCorrect: Value(isCorrect),
          answeredAt: Value(ts),
        ),
      );
    }
  }

  /// 兼容你之前的调用；内部改为使用 upsert
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

  // ===== 读取一场的所有作答 =====
  Future<List<PracticeAnswer>> getAnswersByRun(String runId) =>
      (select(practiceAnswers)
        ..where((t) => t.runId.equals(runId))
        ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
          .get();

  Stream<List<PracticeAnswer>> watchAnswersByRun(String runId) =>
      (select(practiceAnswers)
        ..where((t) => t.runId.equals(runId))
        ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
          .watch();

  // ===== 删除整场（含答案） =====
  Future<void> deleteRunCascade(String runId) async {
    await (delete(practiceAnswers)..where((t) => t.runId.equals(runId))).go();
    await (delete(practiceRuns)..where((t) => t.id.equals(runId))).go();
  }

  /// 按 runId 获取单场记录（用于 RecordDetail 加载）
  Future<PracticeRun?> getRunById(String runId) =>
      (select(practiceRuns)..where((t) => t.id.equals(runId)))
          .getSingleOrNull();
}