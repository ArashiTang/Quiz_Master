import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';

/// 路由参数：只需 quizId 和选项样式（0=ABC, 1=123）
class QuizPreviewArgs {
  final String quizId;
  final int optionStyle;
  const QuizPreviewArgs({required this.quizId, required this.optionStyle});
}

/// 预览内部用的聚合模型
class _PreviewQuestion {
  final Question question;
  final List<QuizOption> options;
  _PreviewQuestion(this.question, this.options);
}

class _PreviewData {
  final Quizze quiz;
  final List<_PreviewQuestion> questions;
  _PreviewData(this.quiz, this.questions);
}

class QuizPreviewPage extends StatelessWidget {
  final QuizDao quizDao;
  const QuizPreviewPage({super.key, required this.quizDao});

  String _labelFor(int index, int style) {
    return style == 0
        ? String.fromCharCode('A'.codeUnitAt(0) + index)
        : '${index + 1}';
  }

  Future<_PreviewData> _loadBundle(String quizId) async {
    final quiz = await quizDao.getQuizById(quizId);
    if (quiz == null) throw StateError('Quiz not found: $quizId');

    final qs = await quizDao.getQuestionsByQuiz(quizId);
    final List<_PreviewQuestion> list = [];
    for (final q in qs) {
      final opts = await quizDao.getOptionsByQuestion(q.id);
      list.add(_PreviewQuestion(q, opts));
    }
    return _PreviewData(quiz, list);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as QuizPreviewArgs;

    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: FutureBuilder<_PreviewData>(
        future: _loadBundle(args.quizId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Load failed: ${snap.error}'));
          }

          final data = snap.data!;
          final quiz = data.quiz;
          final questions = data.questions;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 顶部信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title.isEmpty ? '(Untitled Quiz)' : quiz.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text('Option: ${args.optionStyle == 0 ? 'ABC' : '123'}')),
                          Chip(label: Text('Pass: ${quiz.passRate}%')),
                          Chip(label: Text('Scores: ${quiz.enableScores ? 'On' : 'Off'}')),
                        ],
                      ),
                      if (quiz.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(quiz.description),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 题目列表
              for (int i = 0; i < questions.length; i++) ...[
                _QuestionCard(
                  index: i,
                  data: questions[i],
                  optionLabel: (idx) => _labelFor(idx, args.optionStyle),
                ),
                const SizedBox(height: 12),
              ],

              if (questions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: Text('No questions yet')),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final _PreviewQuestion data;
  final String Function(int) optionLabel;

  const _QuestionCard({
    required this.index,
    required this.data,
    required this.optionLabel,
  });

  /// 解析 Question.correctAnswerTexts 里存的 JSON 字符串（["A text", "B text"]）
  List<String> _parseCorrectTexts(String raw) {
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final correctTexts = _parseCorrectTexts(data.question.correctAnswerTexts);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行：题号/类型/分值
              Row(
                children: [
                  Text('Q${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      data.question.questionType == 1 ? 'Multiple' : 'Single',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if ((data.question.score ?? 1) > 0)
                    Chip(label: Text('Score: ${data.question.score ?? 1}')),
                ],
              ),
              const SizedBox(height: 6),

              // 题干
              Text(
                data.question.content.isEmpty
                    ? '(No content)'
                    : data.question.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),

              // 选项
              Column(
                children: [
                  for (int i = 0; i < data.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 36,
                            child: CircleAvatar(
                              radius: 14,
                              child: Text(optionLabel(i)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: correctTexts
                                      .contains(data.options[i].textValue)
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: correctTexts
                                    .contains(data.options[i].textValue)
                                    ? Colors.green.withOpacity(0.06)
                                    : null,
                              ),
                              child: Text(
                                data.options[i].textValue.isEmpty
                                    ? '(Empty option)'
                                    : data.options[i].textValue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}