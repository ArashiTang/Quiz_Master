import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 管理本地头像路径：按邮箱区分
class LocalProfileStorage {
  static const _avatarKeyPrefix = 'avatarPath_';

  /// 根据邮箱读取头像路径（如果有）
  static Future<String?> getAvatarPath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_avatarKeyPrefix$email');
  }

  /// 保存头像路径（如果 path 为 null 则删除）
  static Future<void> setAvatarPath(String email, String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove('$_avatarKeyPrefix$email');
    } else {
      await prefs.setString('$_avatarKeyPrefix$email', path);
    }
  }

  /// 把用户选择的图片复制到应用内部目录，返回新的路径
  static Future<String> saveAvatarFile(String email, File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    // 用邮箱构造一个稳定的文件名（简单做法：替换非法字符）
    final safeEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final ext = p.extension(source.path);
    final targetPath = p.join(avatarsDir.path, '$safeEmail$ext');

    final targetFile = await source.copy(targetPath);
    return targetFile.path;
  }
}