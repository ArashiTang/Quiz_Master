import 'dart:async';
import 'package:flutter/material.dart';

import 'package:quiz_master/core/database/daos/quiz_dao.dart';
import 'package:quiz_master/core/database/db/app_db.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class QuizListPage extends StatefulWidget {
  final QuizDao quizDao;
  const QuizListPage({super.key, required this.quizDao});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}/$mm/$dd';
  }

  @override
  Widget build(BuildContext context) {
    final auth = SupabaseAuthService.instance;

    // The ownerKey (email address or 'guest') is used for database filtering.
    final ownerKey = auth.currentOwnerKey;

    // For title display: Email address is displayed if logged in, otherwise Guest is displayed.
    final ownerLabel = auth.currentUser?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Text('Local ($ownerLabel)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===== search box =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black87, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 26, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 200), () {
                              setState(() {
                                _keyword = v.trim().toLowerCase();
                              });
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Quiz List =====
          Expanded(
            child: StreamBuilder<List<Quizze>>(
              stream: widget.quizDao.watchQuizzesByOwner(ownerKey),
              builder: (context, quizSnap) {
                final list = (quizSnap.data ?? [])
                    .where((q) => _keyword.isEmpty
                    ? true
                    : q.title.toLowerCase().contains(_keyword))
                    .toList();

                if (list.isEmpty) {
                  return const Center(child: Text('No quizzes yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final q = list[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/quizEditor',
                            arguments: q.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q.title.isEmpty
                                          ? 'Untitled Quiz'
                                          : q.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Updated: ${_fmtDate(q.updatedAt)}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 28, color: Colors.white),
                            ],
                          ),
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