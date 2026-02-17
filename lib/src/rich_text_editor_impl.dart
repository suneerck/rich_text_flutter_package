import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'editor_html.dart';
import 'rich_text_editor_controller.dart';

/// Cross-platform rich text editor widget (HTML in / HTML out).
class RichTextEditorImpl extends StatefulWidget {
  const RichTextEditorImpl({
    super.key,
    required this.controller,
    this.initialHtml,
    this.onHtmlChanged,
    this.decoration,
    this.minHeight = 120,
    this.placeholder,
  });

  final RichTextEditorController controller;
  final String? initialHtml;
  final ValueChanged<String>? onHtmlChanged;
  final BoxDecoration? decoration;
  final double minHeight;
  final String? placeholder;

  @override
  State<RichTextEditorImpl> createState() => _RichTextEditorImplState();
}

class _RichTextEditorImplState extends State<RichTextEditorImpl> {
  late final WebViewController _webController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Editor',
        onMessageReceived: _onEditorMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _onPageFinished,
        ),
      )
      ..loadHtmlString(
        kEditorHtml,
        baseUrl: null,
      );
  }

  void _onEditorMessage(JavaScriptMessage message) {
    widget.onHtmlChanged?.call(message.message);
  }

  Future<void> _onPageFinished(String url) async {
    if (!mounted) return;
    widget.controller.attach(_webController);
    final initial = widget.initialHtml ?? widget.controller.pendingHtml;
    if (initial != null && initial.isNotEmpty) {
      await widget.controller.setHtml(initial);
    }
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  @override
  void didUpdateWidget(covariant RichTextEditorImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
      if (_loaded) widget.controller.attach(_webController);
    }
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration ??
          BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(minHeight: widget.minHeight),
      child: WebViewWidget(controller: _webController),
    );
  }
}
