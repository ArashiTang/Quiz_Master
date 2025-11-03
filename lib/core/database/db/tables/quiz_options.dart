import 'package:drift/drift.dart';
import 'questions.dart';

class QuizOptions extends Table {
  TextColumn get id => text()();

  TextColumn get questionId =>
      text().references(Questions, #id, onDelete: KeyAction.cascade)();

  TextColumn get textValue => text()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(question_id, order_index)'];
}