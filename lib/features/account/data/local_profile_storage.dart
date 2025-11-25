import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manage local profile picture paths: differentiated by email address
class LocalProfileStorage {
  static const _avatarKeyPrefix = 'avatarPath_';

  /// Retrieve profile picture path (if applicable) based on email address.
  static Future<String?> getAvatarPath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_avatarKeyPrefix$email');
  }

  /// Save the profile picture path (delete if path is null).
  static Future<void> setAvatarPath(String email, String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove('$_avatarKeyPrefix$email');
    } else {
      await prefs.setString('$_avatarKeyPrefix$email', path);
    }
  }

  /// Copy the image selected by the user to the application's internal directory and return the new path.
  static Future<String> saveAvatarFile(String email, File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    // Construct a stable filename using an email address (simple approach: replace illegal characters).
    final safeEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final ext = p.extension(source.path);
    final targetPath = p.join(avatarsDir.path, '$safeEmail$ext');

    final targetFile = await source.copy(targetPath);
    return targetFile.path;
  }
}