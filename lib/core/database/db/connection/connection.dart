import 'package:drift/drift.dart';

// Web 环境时导入 web.dart，否则导入 native.dart
import 'native.dart' if (dart.library.html) 'web.dart';

QueryExecutor openConnection() => createExecutor();