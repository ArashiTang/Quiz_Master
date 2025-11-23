import 'package:drift/drift.dart';

class Quizzes extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().named('description').withDefault(const Constant(''))();
  IntColumn get optionType => integer().withDefault(const Constant(0))(); // 0=ABC,1=123
  IntColumn get passRate => integer().withDefault(const Constant(60))();
  BoolColumn get enableScores => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get ownerKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}