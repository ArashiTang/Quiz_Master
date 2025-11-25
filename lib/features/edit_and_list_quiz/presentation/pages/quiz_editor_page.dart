import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/utils/ids.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/question_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_preview_page.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class QuizEditorPage extends StatefulWidget {
  final QuizDao quizDao;
  const QuizEditorPage({super.key, required this.quizDao});

  @override
  State<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends State<QuizEditorPage> {
  Quizze? _loaded;
  String? _draftId;
  bool _dirty = false;
  bool _inited = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _auth = SupabaseAuthService.instance;
  int _optionType = 0; // 0 = ABC, 1 = 123
  int _passRate = 60; // 0..100
  bool _enableScores = false;

  // -------------------- Intercepting and returning if not saved --------------------
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
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ignore'),
          ),
        ],
      ),
    );
    return ok == true;
  }
  // -----------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String?) {
      if (args != null) {
        // The quiz has been edited.
        _loadQuiz(args);
      } else {
        // To create a new quiz, first generate a temporary ID for yourself.
        _draftId = newId('edit_and_list_quiz');
      }
    }
  }

  Future<void> _loadQuiz(String id) async {
    final q = await widget.quizDao.getQuizById(id);
    if (q != null) {
      setState(() {
        _loaded = q;
        _titleCtrl.text = q.title;
        _descCtrl.text = q.description;
        _optionType = q.optionType;
        _passRate = q.passRate;
        _enableScores = q.enableScores;
      });
    }
  }

  Future<void> _save() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Current owner:
    final ownerEmail =
        _loaded?.ownerKey ?? SupabaseAuthService.instance.currentOwnerKey;

    final data = QuizzesCompanion(
      id: Value(_loaded?.id ?? _draftId ?? newId('edit_and_list_quiz')),
      title: Value(_titleCtrl.text),
      description: Value(_descCtrl.text),
      optionType: Value(_optionType),
      passRate: Value(_passRate),
      enableScores: Value(_enableScores),
      createdAt: Value(_loaded?.createdAt ?? now),
      updatedAt: Value(now),
      ownerKey: Value(ownerEmail),
    );

    try {
      await widget.quizDao.upsertQuiz(data, ownerEmail);
    } catch (e, st) {
      print('Failed to save quiz: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save quiz: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _loaded = Quizze(
        id: data.id.value,
        title: data.title.value,
        description: data.description.value,
        optionType: data.optionType.value,
        passRate: data.passRate.value,
        enableScores: data.enableScores.value,
        createdAt: data.createdAt.value,
        updatedAt: data.updatedAt.value,
        ownerKey: data.ownerKey.value,
      );
      _draftId = null;
      _dirty = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quiz saved.')));
  }

  Future<void> _uploadToCloud() async {
    if (!_auth.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to upload quiz to cloud.')),
      );
      return;
    }

    // 1. Save locally first to ensure the data is up-to-date.
    await _save();
    if (_loaded == null) return;
    final quiz = _loaded!;
    final quizId = quiz.id;

    try {
      // 2. Retrieve all local questions
      final questions = await widget.quizDao.getQuestionsByQuiz(quizId);

      // Create the JSON for the cloud-based quiz (Note: the cloud table does not need id / owner_id, this part is filled in by the API).
      final cloudQuiz = {
        'title': quiz.title,
        'description': quiz.description,
        'option_type': quiz.optionType,
        'pass_rate': quiz.passRate,
        'enable_scores': quiz.enableScores,
      };

      // ==============================
      // Build cloud_questions / cloud_options
      // ==============================
      final List<Map<String, dynamic>> cloudQuestions = [];
      final List<Map<String, dynamic>> cloudOptions = [];

      for (final q in questions) {
        // cloud_questions are based on the fields in our cloud table.
        cloudQuestions.add({
          'order_index': q.orderIndex,
          'question_type': q.questionType,
          'number_of_options': q.numberOfOptions,
          'content': q.content,
          'correct_answer_texts': q.correctAnswerTexts,
          'score': q.score,
        });

        // Get local options
        final opts = await widget.quizDao.getOptionsByQuestion(q.id);

        for (final o in opts) {
          cloudOptions.add({
            // This field is only used by the service to find the question_id; it will not be directly written into the table.
            'question_order_index': q.orderIndex,
            // This is what is actually written into cloud_options.order_index.
            'order_index': o.orderIndex,
            'text_value': o.textValue,
          });
        }
      }

      // 3. Call service to upload
      final shareCode = await _auth.uploadQuizToCloud(
        quiz: cloudQuiz,
        questions: cloudQuestions,
        options: cloudOptions,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload success! Share code: $shareCode')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _deleteQuiz() async {
    final id = _loaded?.id;
    if (id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please save the quiz first.')),
        );
      }
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this quiz?'),
        content:
        const Text('This will delete the quiz and all its questions & options.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.quizDao.deleteQuizCascade(id);
      _dirty = false;
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ------------------------- Question Navigation Bar -------------------------
  Widget _buildQuestionNav() {
    final quizId = _loaded?.id ?? _draftId;
    if (quizId == null) {
      return const Text('Save quiz first, then add questions.');
    }

    return FutureBuilder<List<Question>>(
      future: widget.quizDao.getQuestionsByQuiz(quizId),
      builder: (context, snap) {
        final items = snap.data ?? const [];
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < items.length; i++)
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/questionEditor',
                    arguments: QuestionEditorArgs(
                      quizId: quizId,
                      questionId: items[i].id,
                      optionStyle: _optionType,
                      enableScores: _enableScores,
                      initialOrder: items[i].orderIndex,
                    ),
                  );
                  if (mounted) setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () async {
                // Before creating a new question, save the quiz once if it hasn't been saved before.
                if (_loaded == null && _draftId != null) {
                  await _save();
                  // If saving fails (an error message will pop up in _save), simply return here.
                  if (_loaded == null) return;
                }
                final id = _loaded?.id ?? _draftId!;
                final count =
                await widget.quizDao.countQuestionsForQuiz(id);

                await Navigator.pushNamed(
                  context,
                  '/questionEditor',
                  arguments: QuestionEditorArgs(
                    quizId: id,
                    questionId: null,
                    optionStyle: _optionType,
                    enableScores: _enableScores,
                    initialOrder: count + 1,
                  ),
                );
                if (mounted) setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black54),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => _dirty = true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              onChanged: (_) => _dirty = true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Option Style:  '),
                ChoiceChip(
                  label: const Text('ABC'),
                  selected: _optionType == 0,
                  onSelected: (_) => setState(() {
                    _optionType = 0;
                    _dirty = true;
                  }),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('123'),
                  selected: _optionType == 1,
                  onSelected: (_) => setState(() {
                    _optionType = 1;
                    _dirty = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Pass Rate:  '),
                Expanded(
                  child: Slider(
                    value: _passRate.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$_passRate%',
                    onChanged: (v) => setState(() {
                      _passRate = v.toInt();
                      _dirty = true;
                    }),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Enable per-question scores'),
              value: _enableScores,
              onChanged: (v) => setState(() {
                _enableScores = v;
                _dirty = true;
              }),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQuestionNav(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final id = _loaded?.id ?? _draftId;
                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please save the quiz first.'),
                    ),
                  );
                  return;
                }
                Navigator.pushNamed(
                  context,
                  '/quizPreview',
                  arguments:
                  QuizPreviewArgs(quizId: id, optionStyle: _optionType),
                );
              },
              child: const Text('Preview'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadToCloud,
                child: const Text('Upload to Cloud'),
              ),
            ),
            TextButton(
              onPressed: _deleteQuiz,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}