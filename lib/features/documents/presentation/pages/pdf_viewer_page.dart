import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerArgs {
  const PdfViewerArgs({required this.filePath, this.fileName});

  final String filePath;
  final String? fileName;
}

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.args});

  final PdfViewerArgs args;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.args.filePath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    await Share.shareXFiles([
      XFile(widget.args.filePath, name: widget.args.fileName),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.args.fileName ?? 'PDF';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          )
        ],
      ),
      body: PdfViewPinch(controller: _controller),
    );
  }
}