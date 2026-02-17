import 'package:flutter/material.dart';

import 'rich_text_editor_controller.dart';
import 'rich_text_editor_impl.dart';

/// Cross-platform rich text editor with HTML input and output.
///
/// Use [initialHtml] or [RichTextEditorController.initialHtml] to set initial
/// content. Use [onHtmlChanged] to receive HTML when the user edits.
/// Use [controller.getHtml()] and [controller.setHtml()] for programmatic access.
class RichTextEditor extends StatelessWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    this.initialHtml,
    this.onHtmlChanged,
    this.decoration,
    this.minHeight = 120,
    this.maxHeight,
    this.placeholder,
  });

  /// Controls the editor (get/set HTML, clear).
  final RichTextEditorController controller;

  /// Optional initial HTML. If both this and [controller] initial HTML are set,
  /// this takes precedence.
  final String? initialHtml;

  /// Called when the editor content changes, with the current HTML.
  final ValueChanged<String>? onHtmlChanged;

  /// Box decoration around the editor (border, background, etc.).
  final BoxDecoration? decoration;

  /// Minimum height of the editor area in logical pixels.
  final double minHeight;

  /// Maximum height of the editor area in logical pixels.
  ///
  /// When the editor is placed inside a scrollable parent (e.g. [ListView]),
  /// which provides unbounded height constraints, this value is used as the
  /// editor's height. If not set, [minHeight] is used as the fallback.
  final double? maxHeight;

  /// Placeholder is defined in the embedded editor; this is reserved for future use.
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return RichTextEditorImpl(
      controller: controller,
      initialHtml: initialHtml,
      onHtmlChanged: onHtmlChanged,
      decoration: decoration,
      minHeight: minHeight,
      maxHeight: maxHeight,
      placeholder: placeholder,
    );
  }
}
