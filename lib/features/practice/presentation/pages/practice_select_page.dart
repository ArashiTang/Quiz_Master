import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class PracticeSelectPage extends StatefulWidget {
  final QuizDao quizDao;
  const PracticeSelectPage({super.key, required this.quizDao});

  @override
  State<PracticeSelectPage> createState() => _PracticeSelectPageState();
}

class _PracticeSelectPageState extends State<PracticeSelectPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5EA), // Go Practice 主题底色
      appBar: AppBar(
        title: const Text('Practice'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 列表
          Expanded(
            child: StreamBuilder<List<Quizze>>(
              stream: widget.quizDao.watchQuizzesByOwner(SupabaseAuthService.instance.currentOwnerKey),
              builder: (context, snap) {
                final all = snap.data ?? const <Quizze>[];
                final kw = _search.text.trim().toLowerCase();
                final items = kw.isEmpty
                    ? all
                    : all
                    .where((q) =>
                    (q.title).toLowerCase().contains(kw))
                    .toList();

                if (items.isEmpty) {
                  return const Center(child: Text('No quizzes found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final q = items[i];
                    final updated =
                    DateTime.fromMillisecondsSinceEpoch(q.updatedAt);
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/practiceRun',
                          arguments: q.id, // 只传 quizId 即可
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // 白卡片 + 绿色背景
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              color: Color(0x22000000),
                            ),
                          ],
                        ),
                        padding:
                        const EdgeInsets.fromLTRB(16, 18, 12, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 左侧文本
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.title.isEmpty
                                        ? 'Quiz Name'
                                        : q.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${updated.year.toString().padLeft(4, '0')}/${updated.month.toString().padLeft(2, '0')}/${updated.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black54,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
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