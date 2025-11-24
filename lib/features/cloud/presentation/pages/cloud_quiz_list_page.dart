import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/remote/supabase_auth_service.dart';

class CloudQuizListPage extends StatefulWidget {
  static const routeName = '/cloudQuizList';

  const CloudQuizListPage({Key? key}) : super(key: key);

  @override
  State<CloudQuizListPage> createState() => _CloudQuizListPageState();
}

class _CloudQuizListPageState extends State<CloudQuizListPage> {
  final _auth = SupabaseAuthService.instance;

  /// 这里保存 CloudQuizSummary，而不是 Map
  List<CloudQuizSummary> _cloudQuizzes = [];

  String _search = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCloudQuizzes();
  }

  Future<void> _loadCloudQuizzes() async {
    if (!_auth.isLoggedIn) return;

    setState(() => _loading = true);

    try {
      final quizzes = await _auth.fetchMyCloudQuizList();
      if (!mounted) return;
      setState(() {
        _cloudQuizzes = quizzes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cloud quizzes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePurple = const Color(0xFFE7F0FF);

    final filtered = _cloudQuizzes.where((q) {
      final name = q.title.toLowerCase();
      return name.contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: themePurple,
      appBar: AppBar(
        title: const Text(
          'Cloud',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themePurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) {
                setState(() => _search = v);
              },
            ),
          ),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final q = filtered[i];
                  final title = q.title;
                  final dateStr =
                  DateFormat('yyyy/MM/dd').format(q.createdAt);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/cloudQuizDetail',
                        arguments: q,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9EA8FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Author: Me'),
                          Text('Date: $dateStr'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}