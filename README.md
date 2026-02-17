# rich_text_editor

A cross-platform Flutter rich text editor with **HTML input and HTML output**. Same content model as the web: you pass in HTML and get HTML back. Works on **Android**, **iOS**, **Web**, **macOS**, and **Windows** (where WebView is supported).

## Features

- **HTML in, HTML out** – Set initial content and read current content as HTML.
- **WYSIWYG toolbar** – Bold, italic, underline, link, bullet list, numbered list.
- **Cross-platform** – One API for mobile, desktop, and web.
- **No external servers** – Editor runs in an embedded WebView with bundled HTML/JS.

## Supported platforms

| Platform | Support |
|----------|--------|
| Android  | ✅ (SDK 19+) |
| iOS      | ✅ (11.0+)   |
| Web      | ✅ (use `webview_flutter_web`) |
| macOS    | ✅ (10.14+)  |
| Windows  | ✅ (use `webview_flutter_windows` where available) |

For **Web** and **Windows**, add the corresponding implementation to your app’s `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  rich_text_editor:
    path: ../rich_text_editor   # or from pub
  webview_flutter: ^4.10.0
  # For Web:
  webview_flutter_web: ^0.2.0
  # For Windows (if you use a Windows WebView package):
  # webview_flutter_windows: ^x.y.z
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  rich_text_editor:
    path: /path/to/rich_text_editor   # local
  # or when published:
  # rich_text_editor: ^1.0.0
```

Then:

```bash
flutter pub get
```

## Usage

### Basic

```dart
import 'package:rich_text_editor/rich_text_editor.dart';

final controller = RichTextEditorController(
  initialHtml: '<p>Hello <b>world</b></p>',
);

// In your build method:
RichTextEditor(
  controller: controller,
  onHtmlChanged: (html) {
    print('Current HTML: $html');
  },
)
```

### Get / set HTML programmatically

```dart
// Get current content
final html = await controller.getHtml();

// Set content
await controller.setHtml('<p>New <em>content</em></p>');

// Clear
await controller.clear();
```

### With initial HTML from widget

You can pass initial HTML either via the controller or the widget. If both are set, the widget’s `initialHtml` wins.

```dart
RichTextEditor(
  controller: controller,
  initialHtml: '<p>Start here…</p>',
  onHtmlChanged: (html) => saveToBackend(html),
  minHeight: 200,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
)
```

## API summary

| Member | Description |
|--------|-------------|
| `RichTextEditorController({String? initialHtml})` | Controller; optional initial HTML. |
| `RichTextEditor(controller:, initialHtml:, onHtmlChanged:, …)` | The editor widget. |
| `controller.getHtml()` | Returns `Future<String>` with current HTML. |
| `controller.setHtml(String html)` | Sets editor content from HTML. |
| `controller.clear()` | Clears the editor. |
| `controller.isReady` | Whether the WebView is ready for script calls. |

## Example

Run the example app:

```bash
cd example && flutter run
```

## License

BSD-3-Clause (or your chosen license).
