import 'package:drift/drift.dart';
import 'quizzes.dart';

class Questions extends Table {
  TextColumn get id => text()();

  TextColumn get quizId =>
      text().references(Quizzes, #id, onDelete: KeyAction.cascade)();

  IntColumn get questionType => integer().withDefault(const Constant(0))(); // 0=Single,1=Multiple
  IntColumn get numberOfOptions => integer().withDefault(const Constant(4))();
  TextColumn get content => text()(); // Question content

  TextColumn get correctAnswerTexts =>
      text().withDefault(const Constant('[]'))();

  IntColumn get score => integer().withDefault(const Constant(1))();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(quiz_id, order_index)'];
}