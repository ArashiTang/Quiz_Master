import 'dart:math';

String newId(String prefix) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rnd = Random().nextInt(1 << 32).toRadixString(36);
  return '${prefix}_${now}_$rnd';
}

int nowMs() => DateTime.now().millisecondsSinceEpoch;