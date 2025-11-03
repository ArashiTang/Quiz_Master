import 'package:drift/drift.dart';

class PracticeAnswers extends Table {
  TextColumn get id => text()();                 // answerId
  TextColumn get runId => text()();              // 指向 PracticeRuns.id
  TextColumn get questionId => text()();         // 指向 Questions.id
  TextColumn get chosenOptions => text()();      // JSON: ["opt_x","opt_y"]
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  IntColumn  get answeredAt => integer()();      // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}