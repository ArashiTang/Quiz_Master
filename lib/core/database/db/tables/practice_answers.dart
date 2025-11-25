import 'package:drift/drift.dart';

class PracticeAnswers extends Table {
  TextColumn get id => text()();                 // answerId
  TextColumn get runId => text()();              // Point to PracticeRuns.id
  TextColumn get questionId => text()();         // Point to Questions.id
  TextColumn get chosenOptions => text()();      // JSON: ["opt_x","opt_y"]
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  IntColumn  get answeredAt => integer()();      // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}