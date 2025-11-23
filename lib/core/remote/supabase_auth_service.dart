import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// 当前登录的 Supabase 用户（可能为 null）
  User? get currentUser => _client.auth.currentUser;

  /// 是否已登录
  bool get isLoggedIn => currentUser != null;

  /// 当前本地数据的 ownerKey：
  /// - 未登录：'Guest'
  /// - 已登录：用户邮箱
  String get currentOwnerKey {
    final user = currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return 'Guest';
    }
    return email;
  }

  // =========================================================
  // 登录
  // =========================================================
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // 这里不再操作本地 userDao / localUser 表
    // 本地 quiz / record 的 ownerKey 直接用 currentOwnerKey 计算即可

    return res;
  }

  // =========================================================
  // 注册（OTP）
  // =========================================================
  Future<void> sendSignupOtp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<User> verifySignupOtpAndCreateProfile({
    required String email,
    required String token,
    required String username,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );

    final user = res.user ?? _client.auth.currentUser;
    if (user == null) {
      throw Exception('OTP verified but user is null.');
    }

    // 同步一份 profile 到 Supabase 表
    await _client.from('profiles').upsert({
      'id': user.id,
      'username': username,
    });

    // 不再在本地维护 "active user"，直接用 Supabase currentUser

    return user;
  }

  // =========================================================
  // 重置密码（OTP）
  // =========================================================
  Future<void> sendResetOtp({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyResetOtpAndSignIn({
    required String email,
    required String token,
  }) async {
    final res = await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );

    if (res.user == null && _client.auth.currentUser == null) {
      throw Exception('Password reset verification failed.');
    }

    // 通过后 Supabase 会让该用户成为当前用户
    // 本地 ownerKey 通过 currentOwnerKey 计算
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // =========================================================
  // 登出
  // =========================================================
  Future<void> signOut() async {
    await _client.auth.signOut();
    // 不再调用 userDao；登出后 currentUser 变 null，
    // currentOwnerKey 会自动回到 'Guest'
  }

  // =========================================================
  // 获取用户 profile 显示在 Mine
  // =========================================================
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      return {
        'id': null,
        'email': 'Guest',
        'username': 'Guest',
      };
    }

    final meta = user.userMetadata ?? {};
    final name = (meta['username'] as String?)?.trim();

    return {
      'id': user.id,
      'email': user.email,
      'username': (name == null || name.isEmpty) ? 'Guest' : name,
    };
  }

  /// 修改用户名（同时更新 auth.metadata 和 Supabase profiles 表）
  Future<void> updateUsername(String newUsername) async {
    final user = currentUser;
    if (user == null) throw Exception('Not logged in');

    final n = newUsername.trim();
    if (n.isEmpty) throw Exception('Username cannot be empty.');

    await _client.auth.updateUser(
      UserAttributes(data: {'username': n}),
    );

    await _client.from('profiles').update({'username': n}).eq('id', user.id);
  }
}