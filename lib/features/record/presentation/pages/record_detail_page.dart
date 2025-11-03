import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';

class RecordDetailPage extends StatefulWidget {
  final String runId;
  final PracticeDao practiceDao;
  final QuizDao quizDao;
  const RecordDetailPage({
    super.key,
    required this.runId,
    required this.practiceDao,
    required this.quizDao,
  });

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  PracticeRun? _run;
  Quizze? _quiz;
  List<Question> _questions = const [];
  Map<String, List<QuizOption>> _opts = {};
  Map<String, PracticeAnswer> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final run = await widget.practiceDao.getRunById(widget.runId);
    if (run == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final quiz = await widget.quizDao.getQuiz(run.quizId);
    final qs = await widget.quizDao.getQuestionsByQuiz(run.quizId);
    final ans = await widget.practiceDao.getAnswersByRun(widget.runId);

    final Map<String, PracticeAnswer> ansMap = {
      for (final a in ans) a.questionId: a
    };

    final Map<String, List<QuizOption>> optMap = {};
    for (final q in qs) {
      optMap[q.id] = await widget.quizDao.getOptionsByQuestion(q.id);
    }

    setState(() {
      _run = run;
      _quiz = quiz;
      _questions = qs;
      _answers = ansMap;
      _opts = optMap;
    });
  }

  String _formatDuration() {
    final s = _run?.startedAt;
    final e = _run?.endedAt ?? _run?.startedAt;
    if (s == null || e == null) return '--:--';
    final d = Duration(milliseconds: e - s);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _quiz?.title ?? 'Quiz Name';
    final scoreStr = _run?.score?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete this record?'),
                  content: const Text(
                      'This will remove this practice run and its answers.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true) {
                await widget.practiceDao.deleteRunCascade(widget.runId);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 概览：用时 & 成绩
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time: ${_formatDuration()}',
                  style: const TextStyle(fontSize: 16)),
              Text('Score: $scoreStr',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),

          // 逐题展示
          for (int i = 0; i < _questions.length; i++)
            _QuestionBlock(
              index: i,
              q: _questions[i],
              options: _opts[_questions[i].id] ?? const [],
              answer: _answers[_questions[i].id],
            ),
        ],
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  final int index;
  final Question q;
  final List<QuizOption> options;
  final PracticeAnswer? answer;
  const _QuestionBlock({
    required this.index,
    required this.q,
    required this.options,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> correctIds = _parseCorrect(q.correctAnswerIds);
    final Set<String> chosen =
    _parseChosen(answer?.chosenOptions ?? '[]');

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${index + 1}. ${q.content}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (int i = 0; i < options.length; i++)
            _optionLine(options[i], i, correctIds, chosen),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _optionLine(
      QuizOption opt,
      int idx,
      Set<String> correctIds,
      Set<String> chosen,
      ) {
    // 你的选择：红色（错）/绿色（对）
    // 正确答案：绿色
    final bool isChosen = chosen.contains(opt.id);
    final bool isCorrect = correctIds.contains(opt.id);

    Color color;
    if (isChosen && isCorrect) {
      color = Colors.green;
    } else if (isChosen && !isCorrect) {
      color = Colors.red;
    } else if (!isChosen && isCorrect) {
      color = Colors.green;
    } else {
      color = Colors.black87;
    }

    final label = String.fromCharCode('A'.codeUnitAt(0) + idx);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label. ',
              style: TextStyle(fontSize: 16, color: color)),
          Expanded(
            child: Text(
              opt.textValue,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
          // 小圆点（视觉提示）
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isChosen && isCorrect)
                  ? Colors.green
                  : (isChosen && !isCorrect)
                  ? Colors.red
                  : (isCorrect ? Colors.green : Colors.grey.shade300),
            ),
          ),
        ],
      ),
    );
  }

  static Set<String> _parseCorrect(String json) {
    if (json.isEmpty) return {};
    try {
      final List decoded = jsonDecode(json);
      return decoded.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  static Set<String> _parseChosen(String json) {
    try {
      final List decoded = jsonDecode(json);
      return decoded.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }
}