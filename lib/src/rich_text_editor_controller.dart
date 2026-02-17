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
  bool _settingHtml = false;

  /// Whether the WebView has loaded and is ready for script calls.
  bool get isReady => _ready;

  /// Whether a programmatic [setHtml] is currently in progress.
  /// Used internally by the editor widget to skip echo events.
  bool get isSettingHtml => _settingHtml;

  /// Pending HTML to apply when the WebView attaches (e.g. from constructor).
  String? get pendingHtml => _pendingHtml;

  /// Called by the editor widget when the user edits content.
  /// Updates the cached [text] value without sending it back to the WebView.
  ///
  /// You do not need to call this yourself — the [RichTextEditor] widget
  /// calls it automatically on every edit.
  void updateFromEditor(String html) {
    if (_settingHtml) return;
    _currentHtml = html;
    notifyListeners();
  }

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
    _settingHtml = true;
    final escaped = jsonEncode(html);
    await _webController!.runJavaScript(
      'window.__setEditorContent && window.__setEditorContent($escaped);',
    );
    _settingHtml = false;
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

  // ── Programmatic formatting commands ──

  Future<void> _exec(String command, [String? value]) async {
    if (_webController == null || !_ready) return;
    final escaped = value != null ? jsonEncode(value) : 'null';
    await _webController!.runJavaScript(
      'document.execCommand("$command", false, $escaped);',
    );
  }

  /// Toggle bold on the current selection.
  Future<void> toggleBold() => _exec('bold');

  /// Toggle italic on the current selection.
  Future<void> toggleItalic() => _exec('italic');

  /// Toggle underline on the current selection.
  Future<void> toggleUnderline() => _exec('underline');

  /// Toggle strikethrough on the current selection.
  Future<void> toggleStrikethrough() => _exec('strikeThrough');

  /// Toggle subscript on the current selection.
  Future<void> toggleSubscript() => _exec('subscript');

  /// Toggle superscript on the current selection.
  Future<void> toggleSuperscript() => _exec('superscript');

  /// Insert or toggle a bullet (unordered) list.
  Future<void> insertUnorderedList() => _exec('insertUnorderedList');

  /// Insert or toggle a numbered (ordered) list.
  Future<void> insertOrderedList() => _exec('insertOrderedList');

  /// Increase indent level of the current block.
  Future<void> indent() => _exec('indent');

  /// Decrease indent level of the current block.
  Future<void> outdent() => _exec('outdent');

  /// Set the block format (e.g. 'p', 'h1', 'h2', 'h3', 'blockquote', 'pre').
  Future<void> formatBlock(String tag) => _exec('formatBlock', tag);

  /// Align text left.
  Future<void> alignLeft() => _exec('justifyLeft');

  /// Align text center.
  Future<void> alignCenter() => _exec('justifyCenter');

  /// Align text right.
  Future<void> alignRight() => _exec('justifyRight');

  /// Set the foreground (text) color. Accepts hex (e.g. '#ff0000').
  Future<void> setTextColor(String hexColor) => _exec('foreColor', hexColor);

  /// Set the background (highlight) color. Accepts hex (e.g. '#ffff00').
  Future<void> setHighlightColor(String hexColor) =>
      _exec('hiliteColor', hexColor);

  /// Set the font family (e.g. 'serif', 'monospace').
  Future<void> setFontFamily(String family) => _exec('fontName', family);

  /// Insert a horizontal rule at the cursor.
  Future<void> insertHorizontalRule() => _exec('insertHorizontalRule');

  /// Insert a link wrapping the current selection.
  Future<void> insertLink(String url) => _exec('createLink', url);

  /// Insert an image at the cursor position by URL.
  Future<void> insertImage(String url) => _exec('insertImage', url);

  /// Remove all formatting from the current selection.
  Future<void> clearFormatting() => _exec('removeFormat');
}
