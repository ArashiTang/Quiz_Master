import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/daos/practice_dao.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

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
  final TextEditingController _search = TextEditingController();
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() {
        _keyword = _search.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _fmtPercent(num p) {
    final s = p.toStringAsFixed(1);
    return s.endsWith(".0") ? s.substring(0, s.length - 2) : s;
  }

  @override
  Widget build(BuildContext context) {
    // 当前 ownerKey：已登录 = 邮箱，未登录 = 'Guest'
    final ownerKey = SupabaseAuthService.instance.currentOwnerKey;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5E5),
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("Record"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 记录列表
          Expanded(
            child: StreamBuilder<List<PracticeRun>>(
              stream: widget.practiceDao.watchRunsByOwner(ownerKey),
              builder: (context, runSnap) {
                final runs = runSnap.data ?? const <PracticeRun>[];
                if (runs.isEmpty) {
                  return const Center(child: Text("No records yet"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: runs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final run = runs[i];

                    // 读取 quiz 信息
                    return FutureBuilder<Quizze?>(
                      future: widget.quizDao.getQuizById(run.quizId),
                      builder: (context, quizSnap) {
                        final quiz = quizSnap.data;
                        final title = quiz?.title ?? "(Untitled Quiz)";

                        // 搜索过滤
                        if (_keyword.isNotEmpty &&
                            !title
                                .toLowerCase()
                                .contains(_keyword.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        // 加载题目用于计算总分
                        return FutureBuilder<List<Question>>(
                          future: widget.quizDao.getQuestionsByQuiz(run.quizId),
                          builder: (context, questionSnap) {
                            final qs =
                                questionSnap.data ?? const <Question>[];

                            String percent = "--%";
                            if (quiz != null && run.score != null) {
                              final enableScores =
                                  quiz.enableScores ?? false;
                              final total = enableScores
                                  ? qs.fold<int>(
                                0,
                                    (sum, q) =>
                                sum + (q.score ?? 1),
                              )
                                  : qs.length;

                              if (total > 0) {
                                final pct =
                                    (run.score! / total) * 100.0;
                                percent = "${_fmtPercent(pct)}%";
                              }
                            }

                            final date = DateTime
                                .fromMillisecondsSinceEpoch(
                              (run.endedAt ?? run.startedAt),
                            );

                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/recordDetail",
                                  arguments: run.id,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                      color: Color(0x22000000),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    16, 18, 12, 18),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Score: $percent",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            "Date: ${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 28,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            );
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