import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/test_result.dart';
import '../../data/online_test_api.dart';

class TestResultPage extends StatefulWidget {
  const TestResultPage({super.key, required this.testId});

  final String testId;

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  final _api = OnlineTestApi(Supabase.instance.client);
  bool _loading = true;
  List<TestResult> _results = [];
  StreamSubscription<List<TestResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenResults();
  }

  void _listenResults() {
    _subscription?.cancel();
    _subscription = _api.watchResults(widget.testId).listen(
          (items) {
        setState(() {
          _results = items;
          _loading = false;
        });
      },
      onError: (_) {
        setState(() {
          _loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passCount = _results.where((r) => r.result == 'pass').length;
    final failCount = _results.length - passCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: const Color(0xFFB5A7FF),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTable(),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: _results.isEmpty
                  ? const Center(child: Text('No data'))
                  : _PieChart(pass: passCount, fail: failCount),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade200,
            child: const Row(
              children: [
                Expanded(child: Center(child: Text('Participants'))),
                Expanded(child: Center(child: Text('Scores'))),
                Expanded(child: Center(child: Text('Results'))),
              ],
            ),
          ),
          ..._results.map(
                (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                      child: Center(child: Text(r.userName.isEmpty ? '-' : r.userName))),
                  Expanded(child: Center(child: Text('${r.scorePercent.toStringAsFixed(2)}%'))),
                  Expanded(
                      child: Center(
                          child: Text(r.result[0].toUpperCase() + r.result.substring(1)))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.pass, required this.fail});

  final int pass;
  final int fail;

  @override
  Widget build(BuildContext context) {
    final total = (pass + fail).toDouble();
    final passAngle = total == 0 ? 0.0 : (pass / total) * 2 * math.pi;
    final failAngle = total == 0 ? 0.0 : (fail / total) * 2 * math.pi;

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            painter: _PiePainter(passAngle: passAngle, failAngle: failAngle),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Text('Pass rate ${(total == 0 ? 0 : (pass / total * 100)).toStringAsFixed(0)}%')
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.passAngle, required this.failAngle});

  final double passAngle;
  final double failAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Offset.zero & size;

    paint.color = Colors.green;
    canvas.drawArc(rect, -math.pi / 2, passAngle, true, paint);

    paint.color = Colors.red;
    canvas.drawArc(rect, -math.pi / 2 + passAngle, failAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}