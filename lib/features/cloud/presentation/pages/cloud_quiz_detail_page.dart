import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/remote/supabase_auth_service.dart';

class CloudQuizDetailPage extends StatefulWidget {
  const CloudQuizDetailPage({
    Key? key,
    required this.summary,
  }) : super(key: key);

  final CloudQuizSummary summary;

  @override
  State<CloudQuizDetailPage> createState() => _CloudQuizDetailPageState();
}

class _CloudQuizDetailPageState extends State<CloudQuizDetailPage> {
  final _client = Supabase.instance.client;

  bool _loading = false;
  String? _errorText;

  Map<String, dynamic>? _quizRow;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    _loadCloudQuiz();
  }

  Future<void> _loadCloudQuiz() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      // 1. quiz 本体
      final quizRes = await _client
          .from('cloud_quizzes')
          .select()
          .eq('id', widget.summary.id)
          .maybeSingle();

      if (quizRes == null) {
        setState(() {
          _errorText = 'Quiz not found.';
        });
        return;
      }

      final quizRow = quizRes as Map<String, dynamic>;

      // 2. questions，按 order_index 排序
      final questionsRes = await _client
          .from('cloud_questions')
          .select()
          .eq('quiz_id', widget.summary.id)
          .order('order_index', ascending: true);

      final questions =
      (questionsRes as List).cast<Map<String, dynamic>>();

      // 3. options – 逐题查询，按 order_index 排序
      final List<Map<String, dynamic>> allOptions = [];
      for (final q in questions) {
        final qId = q['id'] as String;
        final optsRes = await _client
            .from('cloud_options')
            .select()
            .eq('question_id', qId)
            .order('order_index', ascending: true);
        allOptions
            .addAll((optsRes as List).cast<Map<String, dynamic>>());
      }

      setState(() {
        _quizRow = quizRow;
        _questions = questions;
        _options = allOptions;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Failed to load quiz: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _optionsForQuestion(String questionId) {
    return _options.where((o) => o['question_id'] == questionId).toList();
  }

  Future<void> _showShareCodeDialog() async {
    final code = widget.summary.shareCode;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Share Code',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SelectableText(
            code.isEmpty ? '(No share code)' : code,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),

          // ⬇⬇⬇ 自定义 Copy 按钮
          actions: [
            TextButton(
              onPressed: () async {
                if (code.isNotEmpty) {
                  await Clipboard.setData(ClipboardData(text: code));
                  Navigator.of(context).pop();

                  // 提示复制成功
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Text(
                'Copy',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteQuiz() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text(
          'This will delete this quiz from Cloud. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _client
          .from('cloud_quizzes')
          .delete()
          .eq('id', widget.summary.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz deleted from Cloud')),
      );
      Navigator.of(context).pop(); // 返回列表页
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTitle =
        _quizRow?['title'] as String? ?? widget.summary.title;
    final quizDesc = _quizRow?['description'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F0FF),
        foregroundColor: Colors.white,
        title: Text(
          quizTitle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _showShareCodeDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorText != null
          ? Center(
        child: Text(
          _errorText!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  quizTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quizDesc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quizDesc,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 16),
                for (int i = 0; i < _questions.length; i++)
                  _buildQuestionBlock(
                    index: i + 1,
                    question: _questions[i],
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          // 底部 Delete 按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _deleteQuiz,
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBlock({
    required int index,
    required Map<String, dynamic> question,
  }) {
    final qText = question['content'] as String? ?? '';
    final options = _optionsForQuestion(question['id'] as String);

    // correct_answer_ids: Supabase 里是 text(JSON)，这里做兼容解析
    List<int> correctOrderIndexes = [];
    final raw = question['correct_answer_ids'];

    if (raw is List) {
      // 如果以后你把列类型改成 jsonb，这里也 OK
      correctOrderIndexes =
          raw.map((e) => (e as num).toInt()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          correctOrderIndexes = decoded
              .map((e) => (e as num).toInt())
              .toList();
        }
      } catch (_) {
        // 解析失败就当没有正确答案
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. $qText',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < options.length; i++)
            _buildOptionLine(
              i,
              options[i],
              correctOrderIndexes.contains(
                options[i]['order_index'] as int? ?? -1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionLine(
      int index,
      Map<String, dynamic> option,
      bool isCorrect,
      ) {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final label = index < labels.length ? labels[index] : '?';

    final text = option['text_value'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 15,
              color: isCorrect ? Colors.green : Colors.black,
              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isCorrect ? Colors.green : Colors.black,
                fontWeight:
                isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}