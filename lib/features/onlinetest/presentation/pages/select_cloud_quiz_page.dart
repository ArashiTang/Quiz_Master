import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/remote/supabase_auth_service.dart';
import '../../../../core/remote/supabase_auth_service.dart' show CloudQuizSummary;

class SelectCloudQuizPage extends StatefulWidget {
  const SelectCloudQuizPage({super.key});

  @override
  State<SelectCloudQuizPage> createState() => _SelectCloudQuizPageState();
}

class _SelectCloudQuizPageState extends State<SelectCloudQuizPage> {
  final _client = Supabase.instance.client;
  final _auth = SupabaseAuthService.instance;
  List<CloudQuizSummary> _quizzes = [];
  bool _loading = true;
  String _keyword = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _quizzes = [];
        _loading = false;
        _error = 'Please log in first.';
      });
      return;
    }

    try {
      final res = await _client
          .from('cloud_quizzes')
          .select('id,title,description,owner_id,created_at')
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      final items = (res as List<dynamic>)
          .map((e) => CloudQuizSummary.fromMap(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _quizzes = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load cloud quizzes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _quizzes.where((q) {
      if (_keyword.isEmpty) return true;
      return q.title.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Select Quiz'),
        backgroundColor: const Color(0xFFB5A7FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Hint'),
                  content: Text('Please choose a quiz that has been uploaded to cloud.'),
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _keyword = v.trim()),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final quiz = filtered[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, quiz),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5A7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Author: ${quiz.ownerKey}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Date: ${quiz.createdAt.toIso8601String().split('T').first}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}