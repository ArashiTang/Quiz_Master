import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/utils/ids.dart';

/// Routing parameters: passed in when entering QuizEditor
class QuestionEditorArgs {
  final String quizId;
  final String? questionId; // null indicates a new file.
  final int optionStyle; // 0=ABC, 1=123 (follows the settings of edit_and_list_quiz)
  final bool enableScores; // Follow the settings of edit_and_list_quiz
  final int? initialOrder; // Suggested question order when creating a new question

  const QuestionEditorArgs({
    required this.quizId,
    this.questionId,
    required this.optionStyle,
    required this.enableScores,
    this.initialOrder,
  });
}

class QuestionEditorPage extends StatefulWidget {
  final QuizDao quizDao;
  const QuestionEditorPage({super.key, required this.quizDao});

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  // Routing input parameters
  late String _quizId;
  late int _optionStyle;
  late bool _enableScores;

  // Problem Status
  Question? _loaded; // If the generated class name is QuestionsData, please change it to the corresponding type.
  late String _questionId;
  bool _multiple = false; // false = Single, true = Multiple
  int _optionCount = 4; // 2..8
  int _orderIndex = 1;
  int _score = 1;

  final _stemCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController(text: '1');
  final List<TextEditingController> _optCtrls = [];
  final List<String> _optIds = [];
  final Set<String> _correctIds = {}; // We will still use optionId as the checkmark for "current page".

  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    // First, prepare 4 default option controls.
    for (int i = 0; i < _optionCount; i++) {
      _optCtrls.add(TextEditingController());
      _optIds.add(newId('opt'));
    }
  }

  bool _inited = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final args =
    ModalRoute.of(context)!.settings.arguments as QuestionEditorArgs;
    _quizId = args.quizId;
    _optionStyle = args.optionStyle;
    _enableScores = args.enableScores;
    _initLoad(args);
  }

  Future<void> _initLoad(QuestionEditorArgs a) async {
    if (a.questionId == null) {
      // New
      _questionId = newId('q');
      _orderIndex =
          a.initialOrder ?? (await widget.quizDao.countQuestionsForQuiz(_quizId)) + 1;
      _scoreCtrl.text = '$_score';
      setState(() {});
      return;
    }

    // Edit: Loading questions and options
    _questionId = a.questionId!;
    final q = await widget.quizDao.getQuestionById(_questionId);
    if (q != null) {
      _loaded = q;
      _multiple = q.questionType == 1;
      _optionCount = q.numberOfOptions;
      _orderIndex = q.orderIndex;
      _stemCtrl.text = q.content;
      _score = q.score ?? 1;
      _scoreCtrl.text = '$_score';

      // option
      _optCtrls.clear();
      _optIds.clear();
      final opts = await widget.quizDao.getOptionsByQuestion(q.id);
      for (final o in opts) {
        _optCtrls.add(TextEditingController(text: o.textValue));
        _optIds.add(o.id);
      }

      // Correct answer: It is now "text array".
      _correctIds.clear();
      if (q.correctAnswerTexts.isNotEmpty) {
        try {
          final List decoded = jsonDecode(q.correctAnswerTexts);
          final Set<String> correctTextSet =
          decoded.cast<String>().toSet(); // 正确答案文本集合

          // Based on the "option text", deduce which options are correct and record their optionId.
          for (int i = 0; i < opts.length; i++) {
            final opt = opts[i];
            if (correctTextSet.contains(opt.textValue)) {
              _correctIds.add(opt.id);
            }
          }
        } catch (_) {
          // If there are problems with the historical data format, just ignore them; the system won't crash.
        }
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _stemCtrl.dispose();
    _scoreCtrl.dispose();
    for (final c in _optCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String _labelFor(int index) {
    if (_optionStyle == 0) {
      // ABC...
      return String.fromCharCode('A'.codeUnitAt(0) + index);
    } else {
      // 1-based
      return '${index + 1}';
    }
  }

  void _toggleCorrect(String optId) {
    setState(() {
      if (_multiple) {
        if (_correctIds.contains(optId)) {
          _correctIds.remove(optId);
        } else {
          _correctIds.add(optId);
        }
      } else {
        _correctIds
          ..clear()
          ..add(optId);
      }
      _dirty = true;
    });
  }

  void _addOption() {
    if (_optionCount >= 8) return;
    setState(() {
      _optionCount++;
      _optCtrls.add(TextEditingController());
      _optIds.add(newId('opt'));
      _dirty = true;
    });
  }

  void _removeOption() {
    if (_optionCount <= 2) return;
    setState(() {
      _optionCount--;
      final removedId = _optIds.removeLast();
      _correctIds.remove(removedId);
      _optCtrls.removeLast().dispose();
      _dirty = true;
    });
  }

  Future<void> _save() async {
    // 1. Extract the corresponding option text based on the currently selected optionId list.
    final List<String> correctTexts = [];
    for (int i = 0; i < _optionCount; i++) {
      final id = _optIds[i];
      if (_correctIds.contains(id)) {
        final text = _optCtrls[i].text.trim();
        if (text.isNotEmpty) {
          correctTexts.add(text);
        }
      }
    }

    final qComp = QuestionsCompanion(
      id: Value(_questionId),
      quizId: Value(_quizId),
      questionType: Value(_multiple ? 1 : 0),
      numberOfOptions: Value(_optionCount),
      content: Value(_stemCtrl.text),
      // What's currently stored is a JSON file containing an array of "correct answer texts".
      correctAnswerTexts: Value(jsonEncode(correctTexts)),
      score: Value(_enableScores ? _score : 1),
      orderIndex: Value(_orderIndex),
    );

    await widget.quizDao.upsertQuestion(qComp);

    // Save options in order
    for (int i = 0; i < _optionCount; i++) {
      final oc = QuizOptionsCompanion(
        id: Value(_optIds[i]),
        questionId: Value(_questionId),
        textValue: Value(_optCtrls[i].text),
        orderIndex: Value(i + 1),
      );
      await widget.quizDao.upsertOption(oc);
    }

    _dirty = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved')),
      );
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this question?'),
        content: const Text('This will also delete its options.'),
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
      await widget.quizDao.deleteQuestionCascade(_questionId);
      if (mounted) Navigator.pop(context);
    }
  }

  /// The message simply says "Unsaved," and provides an "Ignore" button (to skip saving and go back).
  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
            'Are you sure you want to go back to the previous page?'),
        content: const Text("You haven't saved yet."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Returns true directly
            child: const Text('Ignore'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final title = (_loaded != null) ? 'Question $_orderIndex' : 'New Question';

    return PopScope(
      canPop: false, // The decision will be made by onPopInvoked.
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final ok = await _confirmDiscard();
        if (ok && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ok = await _confirmDiscard();
              if (ok && mounted) Navigator.of(context).pop();
            },
          ),
          title: Text(title),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // type
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Number of Answers:'),
                ChoiceChip(
                  label: const Text('Single'),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  selected: !_multiple,
                  onSelected: (_) {
                    setState(() {
                      _multiple = false;
                      if (_correctIds.length > 1) {
                        final keep =
                        _correctIds.isEmpty ? null : _correctIds.first;
                        _correctIds.clear();
                        if (keep != null) _correctIds.add(keep);
                      }
                      _dirty = true;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Multiple'),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  selected: _multiple,
                  onSelected: (_) {
                    setState(() {
                      _multiple = true;
                      _dirty = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Number of options
            Row(
              children: [
                const Text('Number of Options:  '),
                IconButton(
                    onPressed: _removeOption, icon: const Icon(Icons.remove)),
                Text('$_optionCount'),
                IconButton(
                    onPressed: _addOption, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 12),

            // Question stem
            const Text('Question Stem'),
            const SizedBox(height: 6),
            TextField(
              controller: _stemCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter text here',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _dirty = true,
            ),
            const SizedBox(height: 16),

            // Options
            const Text('Options'),
            const SizedBox(height: 6),
            for (int i = 0; i < _optionCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _optCtrls[i],
                  decoration: InputDecoration(
                    prefixIcon: CircleAvatar(
                      radius: 12,
                      child: Text(_labelFor(i)),
                    ),
                    hintText: 'Enter text here',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => _dirty = true,
                ),
              ),

            const SizedBox(height: 12),
            // Correct answer
            const Text('Correct Answer'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: List.generate(_optionCount, (i) {
                final id = _optIds[i];
                final selected = _correctIds.contains(id);
                return ChoiceChip(
                  label: Text(_labelFor(i)),
                  selected: selected,
                  onSelected: (_) => _toggleCorrect(id),
                );
              }),
            ),

            if (_enableScores) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Score:  '),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _scoreCtrl,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        setState(() {
                          if (n != null) _score = n;
                          _dirty = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: _delete,
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}