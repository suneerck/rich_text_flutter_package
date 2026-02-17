/// Cross-platform Flutter rich text editor with HTML input and output.
///
/// Supports:
/// - **Web** (with [webview_flutter_web](https://pub.dev/packages/webview_flutter_web))
/// - **Android** (SDK 19+)
/// - **iOS** (11.0+)
/// - **macOS** (10.14+)
/// - **Windows** (with [webview_flutter_windows](https://pub.dev/packages/webview_flutter_windows) if available)
///
/// ## Usage
///
/// ```dart
/// final controller = RichTextEditorController(initialHtml: '<p>Hello</p>');
///
/// RichTextEditor(
///   controller: controller,
///   initialHtml: '<p>Optional initial HTML</p>',
///   onHtmlChanged: (html) => print(html),
/// )
///
/// // Later:
/// final html = await controller.getHtml();
/// await controller.setHtml('<p>New content</p>');
/// ```
library rich_text_flutter;

export 'src/rich_text_editor_controller.dart';
export 'src/rich_text_editor_widget.dart';
