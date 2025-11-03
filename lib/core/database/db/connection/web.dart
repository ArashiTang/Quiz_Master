import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createExecutor() {
  // 旧 API 虽然 deprecated，但稳定可用，先用它保证能跑通
  // ignore: deprecated_member_use
  return WebDatabase('quizmaster');
}