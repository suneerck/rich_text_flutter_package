import 'package:flutter/material.dart';
import 'package:rich_text_flutter/rich_text_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rich Text Editor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _controller = RichTextEditorController(
    initialHtml: '<p>Hello, <strong>rich text</strong> editor!</p>',
  );
  String _lastHtml = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Text Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Get HTML',
            onPressed: () async {
              final html = await _controller.getHtml();
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Current HTML'),
                  content: SingleChildScrollView(
                    child: SelectableText(html.isEmpty ? '(empty)' : html),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit below; input and output are HTML.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RichTextEditor(
                controller: _controller,
                initialHtml: '<p>Type here…</p>',
                onHtmlChanged: (html) {
                  setState(() => _lastHtml = html);
                },
                minHeight: 200,
              ),
            ),
            if (_lastHtml.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Last change (preview):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SizedBox(
                height: 80,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _lastHtml,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
