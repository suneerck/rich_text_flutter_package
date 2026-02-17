## 1.0.9

- **Fixed `controller.text` returning empty in edit mode and `onHtmlChanged` firing only once then stopping.**
- Simplified JS change detection: removed dedup (`_lastSentHtml`) and debounce which could get stuck and silently block all subsequent change events.
- `sendToFlutter` now always posts the current HTML — simple and reliable.
- `_programmatic` flag in JS suppresses events only during `__setEditorContent` (synchronous).
- Dart-side `_settingHtml` guard skips the entire `_onEditorMessage` handler while `setHtml` is in flight, preventing stale/empty content from overwriting `_currentHtml`.

## 1.0.7

- Made `controller.text` sync robust across all platforms by adding `MutationObserver`, `keyup`, `compositionend`, and `blur` event listeners alongside `input`.
- Deduplicates messages so the same HTML is not posted twice.
- `__setEditorContent` now updates the sent-cache to prevent echo on `setHtml`.

## 1.0.6

- Fixed `invalid_use_of_protected_member` warning that prevented `controller.text` from syncing with live editor content.

## 1.0.5

- Added `updateFromEditor` so `controller.text` stays in sync with user edits in the editor.

## 1.0.4

- Fixed editor internal scroll not working when placed inside a scrollable parent (`SingleChildScrollView`, `ListView`, etc.).
- Uses `EagerGestureRecognizer` so the WebView correctly claims touch events in nested scroll scenarios.

## 1.0.3

- Fixed editor not scrolling when content exceeds visible area.
- Toolbar now stays pinned at the top with internal scroll for the editor body.

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
