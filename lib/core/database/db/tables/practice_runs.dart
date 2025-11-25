import 'package:drift/drift.dart';

class PracticeRuns extends Table {
  TextColumn get id => text()();                 // runId
  TextColumn get quizId => text()();             // Point to quizzes.id
  IntColumn  get startedAt => integer()();       // ms since epoch
  IntColumn  get endedAt => integer().nullable()(); // End time, can be empty
  IntColumn  get score => integer().withDefault(const Constant(0))();
  TextColumn get ownerKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}