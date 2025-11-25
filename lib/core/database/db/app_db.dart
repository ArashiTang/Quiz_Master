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
      // Initial installation: Create all current tables and fields directly
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Special Note:
      // Previously, there was an `if (from < 3) { addColumn(quizzes.ownerKey) }` statement here.
      // Example: Add `owner_key` to `practice_runs` when upgrading from 3 to 4 (if needed).
      if (from < 4) {
        await m.addColumn(practiceRuns, practiceRuns.ownerKey);
      }

      // If new fields are added in the future, continue adding them below, for example:
      // if (from < 5) { await m.addColumn(...); }
    },
  );
}