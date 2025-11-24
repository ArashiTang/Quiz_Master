import 'package:drift/drift.dart';
import 'connection/connection.dart';

import 'tables/quizzes.dart';
import 'tables/questions.dart';
import 'tables/quiz_options.dart';
import 'tables/practice_runs.dart';
import 'tables/practice_answers.dart';

part 'app_db.g.dart';

@DriftDatabase(
  tables: [
    Quizzes,
    Questions,
    QuizOptions,
    PracticeRuns,
    PracticeAnswers,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // 初次安装：直接创建目前所有表和字段
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // ⚠️ 特别注意：
      // 之前这里有 if (from < 3) { addColumn(quizzes.ownerKey) }
      // 那段一定要删掉！因为现在 schema 里已经自带 ownerKey 了

      // 例：从 3 升级到 4 时给 practice_runs 加 owner_key（如果你需要）
      if (from < 4) {
        await m.addColumn(practiceRuns, practiceRuns.ownerKey);
      }

      // 未来如果有新的字段，在下面继续加，例如：
      // if (from < 5) { await m.addColumn(...); }
    },
  );
}