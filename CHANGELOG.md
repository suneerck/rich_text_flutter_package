## 1.0.2

- Added synchronous `text` getter/setter on `RichTextEditorController` for convenience (works like `TextEditingController.text`).
- Can now set content before the WebView loads: `controller.text = 'Hello';`.

## 1.0.1

- Documentation and metadata improvements.

## 1.0.0

- Initial release.
- Cross-platform rich text editor (Android, iOS, Web, macOS, Windows).
- HTML input and HTML output.
- Toolbar: bold, italic, underline, link, bullet list, numbered list.
- `RichTextEditorController`: `getHtml()`, `setHtml()`, `clear()`.
