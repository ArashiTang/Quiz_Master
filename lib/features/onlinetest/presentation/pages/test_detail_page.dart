import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/test.dart';
import '../../data/online_test_api.dart';
import 'test_result_page.dart';

class TestDetailPage extends StatefulWidget {
  const TestDetailPage({super.key, required this.test});

  final Test test;

  @override
  State<TestDetailPage> createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  late Test _test;
  bool _updating = false;
  final _api = OnlineTestApi(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _test = widget.test;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_test.title),
        backgroundColor: const Color(0xFFB5A7FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCopyBox(),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow Entry'),
              trailing: Switch(
                value: _test.allowEntry,
                onChanged: _updating ? null : _onToggleAllow,
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Test Result'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestResultPage(testId: _test.id),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCopyBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Test Entry Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_test.shareCode),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _test.shareCode));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')));
              },
              child: const Text('Copy'),
            )
          ],
        )
      ],
    );
  }

  Future<void> _onToggleAllow(bool value) async {
    setState(() => _updating = true);
    await _api.updateAllowEntry(_test.id, value);
    setState(() {
      _test = Test(
        id: _test.id,
        shareCode: _test.shareCode,
        title: _test.title,
        quizId: _test.quizId,
        timeLimit: _test.timeLimit,
        allowEntry: value,
        createdByEmail: _test.createdByEmail,
        startAt: _test.startAt,
        endAt: _test.endAt,
        createdAt: _test.createdAt,
      );
      _updating = false;
    });
  }
}