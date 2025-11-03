import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';

class PracticeRunPage extends StatefulWidget {
  final String quizId;
  final QuizDao quizDao;
  final PracticeDao? practiceDao;

  const PracticeRunPage({
    super.key,
    required this.quizId,
    required this.quizDao,
    this.practiceDao,
  });

  @override
  State<PracticeRunPage> createState() => _PracticeRunPageState();
}

class _PracticeRunPageState extends State<PracticeRunPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _runId;
  Timer? _timer;
  int _elapsed = 0;
  String _title = 'Quiz';

  List<Question> _questions = [];
  final Map<String, List<QuizOption>> _opts = {};
  final Map<String, Set<String>> _picked = {};
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final quiz = await widget.quizDao.getQuiz(widget.quizId);
    if (quiz != null) _title = quiz.title.isEmpty ? 'Quiz' : quiz.title;

    final qs = await widget.quizDao.getQuestionsByQuiz(widget.quizId);
    _questions = qs;

    for (final q in _questions) {
      final list = await widget.quizDao.getOptionsByQuestion(q.id);
      _opts[q.id] = list;
      _picked[q.id] = <String>{};
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
    });

    if (widget.practiceDao != null) {
      _runId = await widget.practiceDao!.startRun(widget.quizId);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool _isAnswered(Question q) => _picked[q.id]?.isNotEmpty ?? false;

  void _togglePick(Question q, String optId) {
    final multiple = q.questionType == 1;
    setState(() {
      final set = _picked[q.id]!;
      if (multiple) {
        set.contains(optId) ? set.remove(optId) : set.add(optId);
      } else {
        set
          ..clear()
          ..add(optId);
      }
    });

    if (widget.practiceDao != null && _runId != null) {
      final chosen = _picked[q.id] ?? <String>{}; // Set<String>
      widget.practiceDao!.upsertAnswer(
        runId: _runId!,
        questionId: q.id,
        chosenIds: chosen,
        isCorrect: _judgeCorrect(q, chosen),
      );
    }
  }

  bool _judgeCorrect(Question q, Set<String> chosen) {
    try {
      final List decoded = q.correctAnswerIds.isEmpty ? [] : jsonDecode(q.correctAnswerIds);
      final target = decoded.cast<String>().toSet();
      return target.isNotEmpty && target.length == chosen.length && target.containsAll(chosen);
    } catch (_) {
      return false;
    }
  }

  Future<void> _prev() async {
    if (_index == 0) {
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(content: Text('This is the first question.')),
      );
      return;
    }
    setState(() => _index--);
  }

  Future<void> _nextOrSubmit() async {
    final isLast = _index == _questions.length - 1;
    if (!isLast) {
      setState(() => _index++);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit'),
        content: const Text('Are you sure you want to submit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (ok != true) return;

    int score = 0;
    for (final q in _questions) {
      if (_judgeCorrect(q, _picked[q.id]!)) score += (q.score ?? 1);
    }
    if (widget.practiceDao != null && _runId != null) {
      await widget.practiceDao!.finishRun(_runId!, score);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _openCatalog() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  Widget build(BuildContext context) {
    final ready = _questions.isNotEmpty;
    final q = ready ? _questions[_index] : null;
    final opts = ready ? _opts[q!.id]! : const <QuizOption>[];
    final chosen = ready ? _picked[q!.id]! : <String>{};
    final isLast = ready && _index == _questions.length - 1;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: _openCatalog,
            tooltip: 'Catalog',
          ),
        ],
      ),

      // ======= 目录（右侧抽屉）=======
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Catalog',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _questions.length,
                  itemBuilder: (ctx, i) {
                    final qi = _questions[i];
                    final done = _isAnswered(qi);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // 关闭抽屉
                        setState(() => _index = i); // 跳题
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: done ? Colors.green : Colors.grey,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            done ? '✓' : '',
                            style: TextStyle(
                              fontSize: 12,
                              color: done ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ======= 主内容区 =======
      body: ready
          ? Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _clock,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_index + 1}. ${q!.content}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...opts.map((o) {
                  final selected = chosen.contains(o.id);
                  return ListTile(
                    title: Text(o.textValue),
                    trailing: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    onTap: () => _togglePick(q, o.id),
                  );
                }),
              ],
            ),
          ),

          // 底部按钮
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _prev,
                  child: const Text('Previous'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _nextOrSubmit,
                  child: Text(isLast ? 'Submit' : 'Next'),
                ),
              ),
            ],
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}