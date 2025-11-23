import 'package:flutter/material.dart';

class ChangeNamePage extends StatefulWidget {
  final String initialName;

  const ChangeNamePage({super.key, required this.initialName});

  @override
  State<ChangeNamePage> createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorText = 'User name cannot be empty';
      });
      return;
    }
    Navigator.of(context).pop<String>(text);
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFFB9A6FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Change Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              'Finish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: headerColor,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorText: _errorText,
                ),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}