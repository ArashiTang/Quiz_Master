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

    final quiz = await widget.quizDao.getQuizById(run.quizId);
    final qs = await widget.quizDao.getQuestionsByQuiz(run.quizId);
    final ans = await widget.practiceDao.getAnswersByRun(widget.runId);

    final Map<String, PracticeAnswer> ansMap = {
      for (final a in ans) a.questionId: a,
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

  // ---------- Score/Result Calculation ----------

  int _totalPossible() {
    final enableScores = _quiz?.enableScores ?? false;
    if (!enableScores) return _questions.length;
    // Scoring mode: Accumulate points for each question (default is 1).
    return _questions.fold<int>(0, (acc, q) => acc + (q.score ?? 1));
  }

  int _obtained() {
    final enableScores = _quiz?.enableScores ?? false;
    if (!enableScores) {
      // Non-fractional mode: Count the number of questions where isCorrect == true.
      return _answers.values.where((a) => a.isCorrect == true).length;
    }

    // Score mode: Use `run.score` first; otherwise, calculate the score based on `isCorrect` for each question.
    final stored = _run?.score;
    if (stored != null) return stored;

    int sum = 0;
    for (final q in _questions) {
      final ans = _answers[q.id];
      final add = (ans?.isCorrect == true) ? (q.score ?? 1) : 0;
      sum += add;
    }
    return sum;
  }

  double _percent() {
    final total = _totalPossible();
    if (total <= 0) return 0;
    return (_obtained() / total) * 100.0;
  }

  String _percentText() {
    final p = _percent();
    final s = p.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  ({String text, Color color}) _resultDisplay() {
    final passRate = (_quiz?.passRate ?? 60).toDouble(); // 0-100
    final p = _percent();
    final pass = p >= passRate;
    return (
    text: pass ? 'Pass' : 'Fail',
    color: pass ? Colors.green : Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _quiz?.title ?? 'Quiz Name';
    final result = _resultDisplay();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete this record?'),
                  content: const Text(
                    'This will remove this practice run and its answers.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
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
          // ===== Top 4 lines of information =====
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time Spent: ${_formatDuration()}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Score: ${_percentText()}%',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Result: ${result.text}',
            style: TextStyle(fontSize: 16, color: result.color),
          ),
          const SizedBox(height: 16),

          // ===== Question by question =====
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

  /// Converts a JSON array string to a Set<String>, for example, '["1","2","4"]'
  static Set<String> _parseSet(String jsonStr) {
    if (jsonStr.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    // The correct answer text for the question (Question.correctAnswerTexts JSON string)
    final correctTexts = _parseSet(q.correctAnswerTexts);

    // The ID of the option selected when answering the question (PracticeAnswer.chosenOptions JSON string).
    final chosenIds = _parseSet(answer?.chosenOptions ?? '[]');

    // Map the selected ID to the corresponding option text.
    final chosenTexts = options
        .where((o) => chosenIds.contains(o.id))
        .map((o) => o.textValue)
        .toSet();

    // To determine if an answer is correct: the two sets must be completely identical.
    final isCorrect = chosenTexts.isNotEmpty &&
        chosenTexts.length == correctTexts.length &&
        chosenTexts.containsAll(correctTexts);

    final resultText =
    isCorrect ? 'Correct' : 'Incorrect or Incomplete';
    final resultColor = isCorrect ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number + judgment result
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                '${q.orderIndex}.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                resultText,
                style: TextStyle(
                  color: resultColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Question stem
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            q.content,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        // Option list
        ...options.map((o) {
          final isOptionCorrect = correctTexts.contains(o.textValue);
          final isOptionChosen = chosenTexts.contains(o.textValue);

          // Color of the small dot on the right:
          //  Green: This option is the correct answer.
          //  Gray: Incorrect answer
          final dotColor = isOptionCorrect ? Colors.green : Colors.grey;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                // Option text (correct answer highlighted in green)
                Expanded(
                  child: Text(
                    o.textValue,
                    style: TextStyle(
                      color: isOptionCorrect ? Colors.green : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                // The small dot on the right (whether it's selected).
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isOptionChosen ? dotColor : Colors.grey[300],
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 16),
      ],
    );
  }
}