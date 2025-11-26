import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class DocumentStorage {
  static String _sanitizeOwnerKey(String ownerKey) {
    return ownerKey.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  }

  static Future<Directory> ensureOwnerDirectory({String? ownerKey}) async {
    final key = ownerKey ?? SupabaseAuthService.instance.currentOwnerKey;
    final safeKey = _sanitizeOwnerKey(key);
    final root = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(root.path, 'documents', safeKey));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
  }
}