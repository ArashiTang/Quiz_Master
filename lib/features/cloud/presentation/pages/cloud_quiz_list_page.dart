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

  /// This stores CloudQuizSummary, not Map.
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
    const themePurple = Color(0xFFE7F0FF);
    const cardShadow = BoxShadow(
      blurRadius: 8,
      offset: Offset(0, 4),
      color: Color(0x22000000),
    );

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
        centerTitle: true,
        backgroundColor: themePurple,
        elevation: 0,
      ),
      body: Column(
        children: [
                Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text(
                  'Manage your cloud quizzes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() => _search = v);
                      },
                    ),
                  ],
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
                      ).then((_) {
                        _loadCloudQuizzes();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [cardShadow],
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