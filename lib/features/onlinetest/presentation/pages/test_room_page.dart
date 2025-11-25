import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/online_test_api.dart';
import '../../../../core/remote/supabase_auth_service.dart';

class TestRoomPage extends StatefulWidget {
  const TestRoomPage({super.key});

  @override
  State<TestRoomPage> createState() => _TestRoomPageState();
}

class _TestRoomPageState extends State<TestRoomPage> {
  final _codeCtrl = TextEditingController();
  final _api = OnlineTestApi(Supabase.instance.client);
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5A7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Test Entry Code',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _codeCtrl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _onGo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Go'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (i) {
        if (i == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else if (i == 2) {
          Navigator.pushNamed(context, '/mine');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Test Room'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mine'),
      ],
    );
  }

  Future<void> _onGo() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter code')));
      return;
    }
    setState(() => _loading = true);
    try {
      final test = await _api.fetchByShareCode(code);
      if (test == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('分享码不存在')));
        return;
      }
      if (!test.allowEntry) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('该测试暂未开放')));
        return;
      }
      final email = SupabaseAuthService.instance.currentUserEmail;
      if (email != null) {
        final existed = await _api.findExistingResult(testId: test.id, email: email);
        if (existed != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('你已经参加过这个测试')));
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('进入测试：${test.title} (time limit ${test.timeLimit} mins)'),
        ),
      );
      // TODO: 导入 quiz 并跳转到在线测试答题页
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('加载失败: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}