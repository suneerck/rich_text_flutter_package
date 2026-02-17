/// Inline HTML for the rich text editor (contenteditable + toolbar).
/// Loaded in WebView; communicates with Flutter via JavaScript channels.
const String kEditorHtml = r'''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { box-sizing: border-box; }
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
    }
    body {
      display: flex;
      flex-direction: column;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 16px;
      color: #202124;
      background: #fff;
      padding: 8px;
    }
    #toolbar {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      padding: 6px 0;
      border-bottom: 1px solid #dadce0;
      margin-bottom: 0;
      flex-shrink: 0;
      position: sticky;
      top: 0;
      z-index: 10;
      background: #fff;
    }
    #toolbar button {
      min-width: 36px;
      height: 36px;
      border: none;
      border-radius: 4px;
      background: transparent;
      cursor: pointer;
      font-size: 14px;
      padding: 0 8px;
    }
    #toolbar button:hover { background: #f1f3f4; }
    #toolbar button:active { background: #e8eaed; }
    #toolbar button.active { background: #e8eaed; }
    #editor {
      flex: 1;
      min-height: 0;
      padding: 12px;
      outline: none;
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      line-height: 1.5;
    }
    #editor:empty::before { content: attr(data-placeholder); color: #80868b; }
    #editor ul, #editor ol { padding-left: 24px; margin: 8px 0; }
    #editor a { color: #1a73e8; text-decoration: none; }
    #editor a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div id="toolbar">
    <button type="button" id="cmd-bold" title="Bold">B</button>
    <button type="button" id="cmd-italic" title="Italic">I</button>
    <button type="button" id="cmd-underline" title="Underline">U</button>
    <button type="button" id="cmd-link" title="Link">Link</button>
    <button type="button" id="cmd-ul" title="Bullet list">• List</button>
    <button type="button" id="cmd-ol" title="Numbered list">1. List</button>
  </div>
  <div id="editor" contenteditable="true" data-placeholder="Start typing..."></div>
  <script>
    (function() {
      var editor = document.getElementById("editor");
      var toolbar = document.getElementById("toolbar");

      function getHtml() {
        return editor.innerHTML || "";
      }
      function setHtml(html) {
        editor.innerHTML = html || "";
      }
      function sendToFlutter() {
        if (window.Editor && typeof window.Editor.postMessage === "function") {
          window.Editor.postMessage(getHtml());
        }
      }

      window.__setEditorContent = function(html) {
        setHtml(html);
      };
      window.__getEditorContent = function() {
        return getHtml();
      };

      editor.addEventListener("input", sendToFlutter);
      editor.addEventListener("paste", function(e) {
        e.preventDefault();
        var text = (e.clipboardData || window.clipboardData).getData("text/html") ||
                   (e.clipboardData || window.clipboardData).getData("text/plain");
        document.execCommand("insertHTML", false, text || "");
        sendToFlutter();
      });

      toolbar.querySelector("#cmd-bold").addEventListener("click", function() {
        document.execCommand("bold", false, null);
        editor.focus();
        sendToFlutter();
      });
      toolbar.querySelector("#cmd-italic").addEventListener("click", function() {
        document.execCommand("italic", false, null);
        editor.focus();
        sendToFlutter();
      });
      toolbar.querySelector("#cmd-underline").addEventListener("click", function() {
        document.execCommand("underline", false, null);
        editor.focus();
        sendToFlutter();
      });
      toolbar.querySelector("#cmd-link").addEventListener("click", function() {
        var url = prompt("Enter URL:", "https://");
        if (url) {
          document.execCommand("createLink", false, url);
          editor.focus();
          sendToFlutter();
        }
      });
      toolbar.querySelector("#cmd-ul").addEventListener("click", function() {
        document.execCommand("insertUnorderedList", false, null);
        editor.focus();
        sendToFlutter();
      });
      toolbar.querySelector("#cmd-ol").addEventListener("click", function() {
        document.execCommand("insertOrderedList", false, null);
        editor.focus();
        sendToFlutter();
      });
    })();
  </script>
</body>
</html>
''';
