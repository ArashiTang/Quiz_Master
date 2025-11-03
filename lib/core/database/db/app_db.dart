import 'package:drift/drift.dart';
import 'connection/connection.dart';
import 'tables/quizzes.dart';
import 'tables/questions.dart';
import 'tables/quiz_options.dart';
import 'tables/practice_runs.dart';
import 'tables/practice_answers.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Quizzes, Questions, QuizOptions,PracticeRuns, PracticeAnswers])
class AppDb extends _$AppDb {
  AppDb() : super(openConnection());

  @override
  int get schemaVersion => 2; // 记得 +1

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // 用生成后的 getter，而不是 PracticeRuns() / PracticeAnswers()
        await m.createTable(practiceRuns);
        await m.createTable(practiceAnswers);
      }
    },
  );
}