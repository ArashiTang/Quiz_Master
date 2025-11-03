import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';

class RecordListPage extends StatefulWidget {
  final PracticeDao practiceDao;
  final QuizDao quizDao;
  const RecordListPage({
    super.key,
    required this.practiceDao,
    required this.quizDao,
  });

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _keyword = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Record'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 顶部：Local / Online Segment（先留 UI，Online 暂时不接数据）
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Local')),
                      ButtonSegment(value: 1, label: Text('Online')),
                    ],
                    selected: const {0},
                    onSelectionChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 搜索框（按 Quiz 标题过滤）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 列表
          Expanded(
            child: StreamBuilder<List<PracticeRun>>(
              stream: widget.practiceDao.watchRuns(),
              builder: (context, snap) {
                final runs = snap.data ?? const <PracticeRun>[];
                if (runs.isEmpty) {
                  return const Center(child: Text('No records yet'));
                }
                return ListView.separated(
                  itemCount: runs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final run = runs[i];
                    return FutureBuilder<Quizze?>(
                      future: widget.quizDao.getQuiz(run.quizId),
                      builder: (ctx, qSnap) {
                        final quiz = qSnap.data;
                        final title = quiz?.title ?? '(Untitled Quiz)';
                        // 搜索过滤（基于标题）
                        if (_keyword.isNotEmpty &&
                            !title.toLowerCase().contains(_keyword.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        final date = DateTime.fromMillisecondsSinceEpoch(
                            (run.endedAt ?? run.startedAt));
                        final scoreStr = (run.score == null)
                            ? '--'
                            : '${run.score}';

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: const Color(0xFF9CA6FF).withOpacity(0.6),
                          title: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Score: $scoreStr    Date: '
                                  '${date.year}/${date.month.toString().padLeft(2,'0')}/${date.day.toString().padLeft(2,'0')}',
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/recordDetail',
                              arguments: run.id,
                            );
                          },
                          onLongPress: () async {
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
                              await widget.practiceDao.deleteRunCascade(run.id);
                              // 列表使用 StreamBuilder，删除后会自动刷新
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}