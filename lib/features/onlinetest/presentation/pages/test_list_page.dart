import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/test.dart';
import '../../data/online_test_api.dart';
import 'test_detail_page.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({super.key});

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  final _api = OnlineTestApi(Supabase.instance.client);
  List<Test> _tests = [];
  bool _loading = true;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _api.fetchOwnTests();
    setState(() {
      _tests = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tests.where((t) {
      if (_keyword.isEmpty) return true;
      return t.title.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Test List'),
        backgroundColor: const Color(0xFFB5A7FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final test = filtered[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TestDetailPage(test: test)),
                      ).then((_) => _load());
                    },
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
                            test.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create Date: ${test.createdAt.toIso8601String().split('T').first}',
                            style: const TextStyle(color: Colors.white70),
                          )
                        ],
                      ),
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