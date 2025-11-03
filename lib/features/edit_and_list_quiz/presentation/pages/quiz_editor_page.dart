import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/database/utils/ids.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/question_editor_page.dart';
import 'package:quiz_master/features/edit_and_list_quiz/presentation/pages/quiz_preview_page.dart';

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
  int _optionType = 0;
  int _passRate = 60;
  bool _enableScores = false;

  // -------------------- 新增：确认返回函数 --------------------
  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure you want to go back to the previous page?'),
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
        _loadQuiz(args);
      } else {
        _draftId = newId('edit_and_list_quiz');
      }
    }
  }

  Future<void> _loadQuiz(String id) async {
    final q = await widget.quizDao.getQuiz(id);
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
    final data = QuizzesCompanion(
      id: Value(_loaded?.id ?? _draftId ?? newId('edit_and_list_quiz')),
      title: Value(_titleCtrl.text),
      description: Value(_descCtrl.text),
      optionType: Value(_optionType),
      passRate: Value(_passRate),
      enableScores: Value(_enableScores),
      createdAt: Value(_loaded?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await widget.quizDao.upsertQuiz(data);
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
      );
      _draftId = null;
      _dirty = false; // ✅ 保存后清除修改标记
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quiz saved.')));
  }

  Future<void> _deleteQuiz() async {
    // 只能删除已保存到 DB 的 edit_and_list_quiz
    final id = _loaded?.id; // 你的模型名若是 QuizzeData，请保持一致
    if (id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please save the edit_and_list_quiz first.')),
        );
      }
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this edit_and_list_quiz?'),
        content: const Text('This will delete the edit_and_list_quiz and all its questions & options.'),
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
      // 级联删除（外键 ON DELETE CASCADE 已启用）
      await widget.quizDao.deleteQuizCascade(id);

      // 防止返回时再次触发“未保存”拦截
      _dirty = false;

      if (mounted) {
        // 返回到列表页；列表页用 watchAllQuizzes() 会自动刷新
        Navigator.of(context).pop();
        // 也可以加个提示
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz deleted.')));
      }
    }
  }
  // ------------------------- 题目导航条 -------------------------
  Widget _buildQuestionNav() {
    final quizId = _loaded?.id ?? _draftId;
    if (quizId == null) {
      return const Text('Save edit_and_list_quiz first, then add questions.');
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text('${i + 1}',
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            GestureDetector(
              onTap: () async {
                if (_loaded == null && _draftId != null) {
                  await _save();
                }
                final id = _loaded?.id ?? _draftId!;
                final count = await widget.quizDao.countQuestionsForQuiz(id);
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black54),
                ),
                child: const Text('+',
                    style: TextStyle(color: Colors.black87, fontSize: 18)),
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
      canPop: false, // 我们自己决定何时 pop
      onPopInvoked: (didPop) async {
        if (didPop) return;                    // 系统已处理就不重复
        final ok = await _confirmDiscard();    // 弹框；未改动直接 true
        if (ok && mounted) {
          Navigator.of(context).pop();         // ← 真正返回上一页
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ok = await _confirmDiscard();
              if (ok && mounted) Navigator.of(context).pop(); // ← 手动返回
            },
          ),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('Save'),//, style: TextStyle(color: Colors.white)
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
                  onSelected: (_) =>
                      setState(() => {_optionType = 0, _dirty = true}),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('123'),
                  selected: _optionType == 1,
                  onSelected: (_) =>
                      setState(() => {_optionType = 1, _dirty = true}),
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
                    onChanged: (v) =>
                        setState(() => {_passRate = v.toInt(), _dirty = true}),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Enable per-question scores'),
              value: _enableScores,
              onChanged: (v) =>
                  setState(() => {_enableScores = v, _dirty = true}),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        content: Text('Please save the edit_and_list_quiz first.')),
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
            TextButton(
              onPressed: _deleteQuiz,
              child: const Text('Delete'),
              // 轻微强调为危险操作（不改你的整体样式）
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}