import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Controller for [RichTextEditor]: get/set HTML and run actions.
///
/// Supports a synchronous [text] property similar to [TextEditingController],
/// so you can write `controller.text = '<p>Hello</p>'` at any point — even
/// before the underlying WebView has loaded.
class RichTextEditorController extends ChangeNotifier {
  RichTextEditorController({String? initialHtml})
      : _pendingHtml = initialHtml,
        _currentHtml = initialHtml ?? '';

  WebViewController? _webController;
  String? _pendingHtml;
  String _currentHtml;
  bool _ready = false;

  /// Whether the WebView has loaded and is ready for script calls.
  bool get isReady => _ready;

  /// Pending HTML to apply when the WebView attaches (e.g. from constructor).
  String? get pendingHtml => _pendingHtml;

  /// The current HTML content of the editor.
  ///
  /// **Getter** – returns the last value set via this property, [setHtml],
  /// or the constructor's `initialHtml`. For the live content that may have
  /// been edited by the user, prefer [getHtml()] (async).
  ///
  /// **Setter** – equivalent to calling [setHtml]. Can be called before the
  /// WebView is ready; the value will be applied once it attaches.
  ///
  /// ```dart
  /// controller.text = ticket?.description ?? '';
  /// ```
  String get text => _currentHtml;
  set text(String value) {
    _currentHtml = value;
    setHtml(value);
    notifyListeners();
  }

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
    _currentHtml = html;
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
    if (_webController == null || !_ready) return _pendingHtml ?? _currentHtml;
    final result = await _webController!.runJavaScriptReturningResult(
      'window.__getEditorContent ? window.__getEditorContent() : "";',
    );
    final html = result is String ? result : result.toString();
    _currentHtml = html;
    return html;
  }

  /// Clear the editor content.
  Future<void> clear() => setHtml('');
}
