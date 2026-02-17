import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Controller for [RichTextEditor]: get/set HTML and run actions.
class RichTextEditorController extends ChangeNotifier {
  RichTextEditorController({String? initialHtml}) : _pendingHtml = initialHtml;

  WebViewController? _webController;
  String? _pendingHtml;
  bool _ready = false;

  /// Whether the WebView has loaded and is ready for script calls.
  bool get isReady => _ready;

  /// Pending HTML to apply when the WebView attaches (e.g. from constructor).
  String? get pendingHtml => _pendingHtml;

  /// Attach the WebViewController (called by [RichTextEditor]).
  void attach(WebViewController controller) {
    _webController = controller;
    _ready = true;
    if (_pendingHtml != null) {
      setHtml(_pendingHtml!);
      _pendingHtml = null;
    }
    notifyListeners();
  }

  /// Detach the WebViewController.
  void detach() {
    _webController = null;
    _ready = false;
    notifyListeners();
  }

  /// Set editor content from HTML. Safe to call before the WebView is ready.
  Future<void> setHtml(String html) async {
    if (_webController == null || !_ready) {
      _pendingHtml = html;
      return;
    }
    final escaped = jsonEncode(html);
    await _webController!.runJavaScript(
      'window.__setEditorContent && window.__setEditorContent($escaped);',
    );
  }

  /// Get current editor content as HTML. Returns empty string if not ready.
  Future<String> getHtml() async {
    if (_webController == null || !_ready) return _pendingHtml ?? '';
    final result = await _webController!.runJavaScriptReturningResult(
      'window.__getEditorContent ? window.__getEditorContent() : "";',
    );
    if (result is String) return result;
    return result.toString();
  }

  /// Clear the editor content.
  Future<void> clear() => setHtml('');
}
