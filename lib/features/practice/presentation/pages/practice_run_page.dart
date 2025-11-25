import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';
import 'package:quiz_master/features/onlinetest/data/online_test_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PracticeRunArgs {
  PracticeRunArgs({
    required this.quizId,
    this.testId,
  });

  final String quizId;
  final String? testId;
}

class PracticeRunPage extends StatefulWidget {
  final String quizId;
  final QuizDao quizDao;
  final PracticeDao practiceDao;
  final String? testId;

  const PracticeRunPage({
    super.key,
    required this.quizId,
    required this.quizDao,
    required this.practiceDao,
    this.testId,
  });

  @override
  State<PracticeRunPage> createState() => _PracticeRunPageState();
}

class _PracticeRunPageState extends State<PracticeRunPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _listKey = GlobalKey();
  final _onlineTestApi = OnlineTestApi(Supabase.instance.client);

  Quizze? _quiz;
  final List<Question> _questions = [];
  final Map<String, List<QuizOption>> _options = {}; // qId -> options
  final Map<String, GlobalKey> _qKeys = {}; // Used for directory navigation

  /// Question ID -> Select the optionId set (memory only, not written to the database)
  final Map<String, Set<String>> _picked = {};

  // Timing
  Timer? _timer;
  int _seconds = 0;
  int? _startedAtMs; // The actual start time of entering the page (used for writing to the database).

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    // Read quiz + questions + options
    final quiz = await widget.quizDao.getQuizById(widget.quizId);
    if (quiz == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final qs = await widget.quizDao.getQuestionsByQuiz(widget.quizId);
    final Map<String, List<QuizOption>> optMap = {};
    for (final q in qs) {
      optMap[q.id] = await widget.quizDao.getOptionsByQuestion(q.id);
    }

    // Record the start time and start the timer (memory only).
    _startedAtMs = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });

    setState(() {
      _quiz = quiz;
      _questions
        ..clear()
        ..addAll(qs);
      _options
        ..clear()
        ..addAll(optMap);
      _loading = false;

      // Prepare a key for each question (for directory navigation).
      for (final q in _questions) {
        _qKeys[q.id] = GlobalKey();
      }
    });
  }

  // ---------- Tool: Parsing the correct answer "text array" ----------
  /// The local Questions table currently stores correctAnswerTexts (JSON strings).
  /// This is parsed as Set<String>
  Set<String> _parseCorrectTexts(String raw) {
    if (raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {

    }
    return <String>{};
  }

  String _labelFor(int index) {
    // 0=ABC, 1=123 (using quiz settings)
    final style = _quiz?.optionType ?? 0;
    return style == 0
        ? String.fromCharCode('A'.codeUnitAt(0) + index)
        : '${index + 1}';
  }

  String _formatClock(int s) {
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _openCatalog() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  // -------- Navigate through the table of contents: Close drawer → Wait for animation → Wait for one frame → Measure coordinates → Scroll --------
  Future<void> _jumpToQuestion(String qId) async {
    final itemKey = _qKeys[qId];
    if (itemKey == null) return;

    _scaffoldKey.currentState?.closeEndDrawer(); // 1) Close the drawer
    await Future.delayed(const Duration(milliseconds: 250)); // 2) 等抽屉动画
    await WidgetsBinding.instance.endOfFrame; // 3) Wait for a frame

    final listCtx = _listKey.currentContext;
    final itemCtx = itemKey.currentContext;
    if (listCtx == null || itemCtx == null) return;

    final listBox = listCtx.findRenderObject() as RenderBox;
    final itemBox = itemCtx.findRenderObject() as RenderBox;

    final listTop = listBox.localToGlobal(Offset.zero).dy;
    final itemTop = itemBox.localToGlobal(Offset.zero).dy;

    final delta = itemTop - listTop; // target relative rolling displacement
    final desired = _scrollController.offset + delta - 12; // Leave 12px at the top

    final min = 0.0;
    final max = _scrollController.position.maxScrollExtent;
    final target = desired.clamp(min, max);

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ---------- Answer (memory only) ----------
  void _togglePick(Question q, String optId) {
    final multiple = q.questionType == 1;
    setState(() {
      final set = _picked.putIfAbsent(q.id, () => <String>{});
      if (multiple) {
        set.contains(optId) ? set.remove(optId) : set.add(optId);
      } else {
        set
          ..clear()
          ..add(optId);
      }
    });
    // No data is written to the database until the commit statement is made.
  }

  /// Judgment based on "text":
  /// - Parse the target text set from Question.correctAnswerTexts
  /// - Find the corresponding text set based on the selected optionId.
  /// - If two sets are completely identical, the result is considered correct.
  bool _judgeCorrect(Question q, Set<String> chosen) {
    if (chosen.isEmpty) return false;

    // 1. Analysis of the "Correct Answer Text List" for this question.
    final targetTexts = _parseCorrectTexts(q.correctAnswerTexts);
    if (targetTexts.isEmpty) return false;

    // 2. Find the corresponding text based on the selected optionId.
    final opts = _options[q.id] ?? const <QuizOption>[];
    final chosenTexts = opts
        .where((o) => chosen.contains(o.id))
        .map((o) => o.textValue)
        .toSet();

    // 3. If the text sets are the same, the condition is correct.
    return targetTexts.length == chosenTexts.length &&
        targetTexts.containsAll(chosenTexts);
  }

  // ---------- Exit/Submit ----------

  Future<bool> _confirmExit() async {
    final isTest = widget.testId != null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isTest ? 'Submit and exit?' : 'Exit?'),
        content: Text(
          isTest
              ? 'Exiting the test will submit your current answers.'
              : 'No data will be saved after exiting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isTest ? 'Submit & Exit' : 'Exit'),
          ),
        ],
      ),
    );
    if (ok == true && isTest) {
      await _submit(confirmDialog: false);
      return false;
    }
    return ok == true;
  }

  Future<void> _submit({bool confirmDialog = true}) async {
    if (confirmDialog) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Are you sure you want to submit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    // 1) First, create a run instance (using the page entry time as startedAt).
    final runId = await widget.practiceDao.startRun(
      widget.quizId,
      SupabaseAuthService.instance.currentOwnerKey,
      startedAtMs: _startedAtMs,
    );

    // 2) Calculate your score + write your answer to each question.
    int score = 0;
    int totalScore = 0;
    final enableScores = _quiz?.enableScores ?? false;

    for (final q in _questions) {
      final chosen = _picked[q.id] ?? <String>{};
      final correct = _judgeCorrect(q, chosen);
      final qScore = enableScores ? (q.score ?? 1) : 1;
      totalScore += qScore;
      if (correct) {
        score += qScore;
      }
      await widget.practiceDao.saveAnswer(
        runId: runId,
        questionId: q.id,
        chosenIds: chosen.toList(),
        correct: correct,
      );
    }

    // 3) Write the end time and total score
    await widget.practiceDao.finishRun(runId, score);

    // 4) Online quiz: Write the results back to Supabase
    await _uploadTestResult(
      runId: runId,
      score: score,
      totalScore: totalScore,
    );

    if (!mounted) return;
    if (widget.testId != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else {
      Navigator.pop(context); // Return to selection page
    }
  }

  Future<void> _uploadTestResult({
    required String runId,
    required int score,
    required int totalScore,
  }) async {
    final testId = widget.testId;
    if (testId == null) return;

    final email = SupabaseAuthService.instance.currentUserEmail;
    if (email == null) return;

    final percent = totalScore == 0 ? 0.0 : (score / totalScore * 100);
    final passRate = _quiz?.passRate ?? 60;
    final result = percent >= passRate ? 'pass' : 'fail';
    final userName = SupabaseAuthService
        .instance.currentUser?.userMetadata?['username']
        ?.toString()
        .trim();

    try {
      await _onlineTestApi.submitResult(
        testId: testId,
        userEmail: email,
        userName: userName,
        scorePercent: percent,
        result: result,
        localRecordId: runId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading test results failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quiz = _quiz!;
    return WillPopScope(
      onWillPop: () async {
        // Close the drawer if it's open, otherwise the eject box will pop up.
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeEndDrawer();
          return false;
        }
        return _confirmExit();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // Close the drawer if it's open.
              if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
                _scaffoldKey.currentState?.closeEndDrawer();
                return;
              }
              if (await _confirmExit()) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          title: Text(quiz.title.isEmpty ? '(Untitled)' : quiz.title),
          actions: [
            IconButton(
              onPressed: _openCatalog,
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Catalog',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _formatClock(_seconds),
                style:
                const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        // Right-hand table of contents
        endDrawer: Drawer(
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (_, i) {
                final q = _questions[i];
                final done =
                (_picked[q.id] != null && _picked[q.id]!.isNotEmpty);
                return ListTile(
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: done ? Colors.green : Colors.grey,
                  ),
                  title: Text('Q${i + 1}'),
                  onTap: () => _jumpToQuestion(q.id),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: _questions.length,
            ),
          ),
        ),

        // Build all questions at once: SingleChildScrollView + Column
        body: SingleChildScrollView(
          key: _listKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top information bar (optional)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Chip(
                          label: Text(
                              'Option: ${quiz.optionType == 0 ? 'ABC' : '123'}')),
                      Chip(label: Text('Pass: ${quiz.passRate}%')),
                      Chip(
                          label: Text(
                              'Scores: ${quiz.enableScores ? 'On' : 'Off'}')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Question cards (all shown)
              for (int i = 0; i < _questions.length; i++) ...[
                _QuestionCard(
                  key: _qKeys[_questions[i].id],
                  index: i,
                  question: _questions[i],
                  options:
                  _options[_questions[i].id] ?? const <QuizOption>[],
                  picked: _picked[_questions[i].id] ?? <String>{},
                  labelBuilder: _labelFor,
                  onToggle: (optId) => _togglePick(_questions[i], optId),
                ),
                const SizedBox(height: 12),
              ],

              // Submit at the bottom
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 260,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _submit,
                    child:
                    const Text('Submit', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final List<QuizOption> options;
  final Set<String> picked;
  final String Function(int) labelBuilder;
  final ValueChanged<String> onToggle;

  const _QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.options,
    required this.picked,
    required this.labelBuilder,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final enableScores = (question.score ?? 1) > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Q${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Chip(
                  label:
                  Text(question.questionType == 1 ? 'Multiple' : 'Single'),
                ),
                const SizedBox(width: 8),
                if (enableScores)
                  Chip(label: Text('Score: ${question.score ?? 1}')),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              question.content.isEmpty ? '(No content)' : question.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            Column(
              children: [
                for (int i = 0; i < options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => onToggle(options[i].id),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 36,
                            child: CircleAvatar(
                              radius: 14,
                              child: Text(labelBuilder(i)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: picked.contains(options[i].id)
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: picked.contains(options[i].id)
                                    ? Colors.green.withOpacity(0.06)
                                    : null,
                              ),
                              child: Text(
                                options[i].textValue.isEmpty
                                    ? '(Empty option)'
                                    : options[i].textValue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}