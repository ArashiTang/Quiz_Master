import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/remote/supabase_auth_service.dart';
import '../../data/document_storage.dart';
import 'pdf_viewer_page.dart';

class DocumentListPage extends StatefulWidget {
  const DocumentListPage({super.key});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  final List<File> _files = [];
  bool _loading = true;
  String _ownerLabel = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    final auth = SupabaseAuthService.instance;
    final ownerKey = auth.currentOwnerKey;
    final dir = await DocumentStorage.ensureOwnerDirectory(ownerKey: ownerKey);
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.pdf')
        .toList()
      ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

    if (!mounted) return;
    setState(() {
      _files
        ..clear()
        ..addAll(files);
      _loading = false;
      _ownerLabel = auth.currentUser?.email ?? 'Guest';
    });
  }

  Future<void> _importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final source = File(path);
    final dir = await DocumentStorage.ensureOwnerDirectory();
    var targetPath = p.join(dir.path, p.basename(source.path));
    var counter = 1;
    while (File(targetPath).existsSync()) {
      targetPath = p.join(
        dir.path,
        '${p.basenameWithoutExtension(source.path)}_$counter.pdf',
      );
      counter++;
    }

    await source.copy(targetPath);
    if (!mounted) return;

    await _loadFiles();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF imported to Documents')),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openFile(File file) async {
    final deleted = await Navigator.pushNamed(
      context,
      '/pdfViewer',
      arguments: PdfViewerArgs(
        filePath: file.path,
        fileName: p.basename(file.path),
      ),
    ) as bool?;

    if (!mounted || deleted != true) return;

    await _loadFiles();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Documents ($_ownerLabel)'),
        actions: [
          IconButton(
            onPressed: _loadFiles,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importPdf,
        child: const Icon(Icons.file_download_outlined),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
          ? const Center(child: Text('No PDF files yet'))
          : RefreshIndicator(
        onRefresh: _loadFiles,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: _files.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final file = _files[i];
            final stat = file.statSync();
            return InkWell(
              onTap: () => _openFile(file),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        color: Colors.redAccent, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.basename(file.path),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatSize(stat.size)} · '
                                '${stat.modified.toLocal()}',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.grey, size: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}