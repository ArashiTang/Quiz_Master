import 'package:drift/drift.dart';

class PracticeRuns extends Table {
  TextColumn get id => text()();                 // runId
  TextColumn get quizId => text()();             // 指向 quizzes.id
  IntColumn  get startedAt => integer()();       // ms since epoch
  IntColumn  get endedAt => integer().nullable()(); // 结束时间，可空
  IntColumn  get score => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}