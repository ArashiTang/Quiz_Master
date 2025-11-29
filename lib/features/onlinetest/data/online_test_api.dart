import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/remote/supabase_auth_service.dart';
import 'models/test.dart';
import 'models/test_result.dart';

class OnlineTestApi {
  OnlineTestApi(this._client);

  final SupabaseClient _client;

  /// Create a test instance and return the latest data (including share_code).
  Future<Test> createTest({
    required String title,
    required String quizId,
    required int timeLimit,
    required bool allowEntry,
  }) async {
    final email = SupabaseAuthService.instance.currentUserEmail;
    final inserted = await _client
        .from('test')
        .insert({
      'title': title,
      'quiz_id': quizId,
      'time_limit': timeLimit,
      'allow_entry': allowEntry,
      'created_by_email': email,
    })
        .select()
        .single();

    return Test.fromJson(inserted);
  }

  /// Search by share code
  Future<Test?> fetchByShareCode(String shareCode) async {
    final res = await _client
        .from('test')
        .select()
        .eq('share_code', shareCode)
        .maybeSingle();
    if (res == null) return null;
    return Test.fromJson(res);
  }

  /// Test list created by the current user
  Future<List<Test>> fetchOwnTests() async {
    final email = SupabaseAuthService.instance.currentUserEmail;
    if (email == null) return [];

    final res = await _client
        .from('test')
        .select()
        .eq('created_by_email', email)
        .order('created_at', ascending: false);
    return (res as List<dynamic>)
        .map((e) => Test.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateAllowEntry(String testId, bool allow) async {
    await _client
        .from('test')
        .update({'allow_entry': allow}).eq('id', testId);
  }

  Future<List<TestResult>> fetchResults(String testId) async {
    final res = await _client
        .from('testresult')
        .select()
        .eq('test_id', testId)
        .order('score_percent', ascending: false);

    return (res as List<dynamic>)
        .map((e) => TestResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> findExistingResult({
    required String testId,
    required String email,
  }) async {
    return await _client
        .from('testresult')
        .select('id')
        .eq('test_id', testId)
        .eq('user_email', email)
        .maybeSingle();
  }

  Future<void> submitResult({
    required String testId,
    required String userEmail,
    required double scorePercent,
    required String result,
    String? userName,
    String? localRecordId,
  }) async {
    await _client.from('testresult').insert({
      'test_id': testId,
      'user_email': userEmail,
      'user_name': userName ?? '',
      'score_percent': scorePercent,
      'result': result,
      'submitted_at': DateTime.now().toIso8601String(),
      'local_record_id': localRecordId,
    });
  }

  Future<Test?> fetchById(String id) async {
    final res = await _client
        .from('test')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (res == null) return null;
    return Test.fromJson(res);
  }

  Stream<List<TestResult>> watchResults(String testId) {
    return _client
        .from('testresult')
        .stream(primaryKey: ['id'])
        .eq('test_id', testId)
        .order('score_percent', ascending: false)
        .map(
          (res) => res
          .map((e) => TestResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}