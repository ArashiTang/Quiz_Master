import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../onlinetest/data/online_test_api.dart';
import 'select_cloud_quiz_page.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final _titleCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '30');
  bool _allowEntry = true;
  CloudQuizSummary? _selectedQuiz;
  bool _saving = false;

  final _api = OnlineTestApi(Supabase.instance.client);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
        backgroundColor: const Color(0xFFB5A7FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'Title',
              required: true,
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration.collapsed(hintText: 'Required'),
              ),
            ),
            _buildField(
              label: 'Select Quiz',
              child: InkWell(
                onTap: _selectQuiz,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedQuiz?.title ?? 'Quiz Name',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            _buildField(
              label: 'Time Limit',
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _timeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration.collapsed(hintText: '0'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Minutes'),
                ],
              ),
            ),
            _buildField(
              label: 'Allow Entry',
              child: Switch(
                value: _allowEntry,
                onChanged: (v) => setState(() => _allowEntry = v),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                onPressed: _saving ? null : _onPublish,
                child: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('Required', style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: child,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectQuiz() async {
    final res = await Navigator.push<CloudQuizSummary?>(
      context,
      MaterialPageRoute(builder: (_) => const SelectCloudQuizPage()),
    );
    if (res != null) {
      setState(() => _selectedQuiz = res);
    }
  }

  Future<void> _onPublish() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please input title and select quiz.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final timeLimit = int.tryParse(_timeCtrl.text.trim()) ?? 0;
      final test = await _api.createTest(
        title: _titleCtrl.text.trim(),
        quizId: _selectedQuiz!.id,
        timeLimit: timeLimit,
        allowEntry: _allowEntry,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share code generated:'),
              const SizedBox(height: 8),
              SelectableText(
                test.shareCode,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}