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
    }
    #toolbar {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 2px;
      padding: 6px 8px;
      border-bottom: 1px solid #dadce0;
      flex-shrink: 0;
      position: sticky;
      top: 0;
      z-index: 10;
      background: #fff;
    }
    #toolbar button {
      min-width: 32px;
      height: 32px;
      border: none;
      border-radius: 4px;
      background: transparent;
      cursor: pointer;
      font-size: 13px;
      padding: 0 6px;
      color: #444;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    #toolbar button:hover { background: #f1f3f4; }
    #toolbar button:active { background: #e8eaed; }
    #toolbar button.active { background: #d3e3fd; color: #1a73e8; }
    #toolbar select {
      height: 32px;
      border: 1px solid #dadce0;
      border-radius: 4px;
      background: #fff;
      font-size: 12px;
      padding: 0 4px;
      color: #444;
      cursor: pointer;
      outline: none;
    }
    #toolbar select:hover { background: #f1f3f4; }
    .sep {
      width: 1px;
      height: 24px;
      background: #dadce0;
      margin: 0 4px;
      flex-shrink: 0;
    }
    .color-btn-wrap {
      position: relative;
      display: inline-flex;
      align-items: center;
    }
    .color-btn-wrap input[type="color"] {
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 6px;
      padding: 0;
      border: none;
      cursor: pointer;
      opacity: 0.8;
    }
    .color-btn-wrap input[type="color"]::-webkit-color-swatch-wrapper { padding: 0; }
    .color-btn-wrap input[type="color"]::-webkit-color-swatch {
      border: none;
      border-radius: 0 0 3px 3px;
    }
    #editor {
      flex: 1;
      min-height: 0;
      padding: 12px 16px;
      outline: none;
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      line-height: 1.6;
    }
    #editor:empty::before { content: attr(data-placeholder); color: #80868b; }
    #editor ul, #editor ol { padding-left: 24px; margin: 8px 0; }
    #editor a { color: #1a73e8; text-decoration: none; }
    #editor a:hover { text-decoration: underline; }
    #editor blockquote {
      margin: 8px 0;
      padding: 4px 12px;
      border-left: 3px solid #dadce0;
      color: #5f6368;
    }
    #editor hr {
      border: none;
      border-top: 1px solid #dadce0;
      margin: 12px 0;
    }
    #editor img {
      max-width: 100%;
      height: auto;
      border-radius: 4px;
    }
    #editor h1 { font-size: 1.8em; margin: 12px 0 8px; }
    #editor h2 { font-size: 1.4em; margin: 10px 0 6px; }
    #editor h3 { font-size: 1.15em; margin: 8px 0 4px; }
  </style>
</head>
<body>
  <div id="toolbar">
    <!-- Text style -->
    <button type="button" id="cmd-bold" title="Bold"><b>B</b></button>
    <button type="button" id="cmd-italic" title="Italic"><i>I</i></button>
    <button type="button" id="cmd-underline" title="Underline"><u>U</u></button>
    <button type="button" id="cmd-strikethrough" title="Strikethrough"><s>S</s></button>
    <span class="sep"></span>

    <!-- Headings -->
    <button type="button" id="cmd-h1" title="Heading 1" style="font-size:14px;font-weight:700;">H<sub style="font-size:9px;">1</sub></button>
    <button type="button" id="cmd-h2" title="Heading 2" style="font-size:14px;font-weight:700;">H<sub style="font-size:9px;">2</sub></button>
    <span class="sep"></span>

    <!-- Lists -->
    <button type="button" id="cmd-ol" title="Numbered list" style="font-size:15px;">&#9776;</button>
    <button type="button" id="cmd-ul" title="Bullet list" style="font-size:15px;">&#8803;</button>
    <span class="sep"></span>

    <!-- Subscript / Superscript -->
    <button type="button" id="cmd-subscript" title="Subscript">X<sub style="font-size:9px;">2</sub></button>
    <button type="button" id="cmd-superscript" title="Superscript">X<sup style="font-size:9px;">2</sup></button>
    <span class="sep"></span>

    <!-- Block / Indent -->
    <button type="button" id="cmd-blockquote" title="Block quote" style="font-size:16px;">&#8220;&#182;</button>
    <button type="button" id="cmd-indent" title="Increase indent" style="font-size:15px;">&#8677;</button>
    <button type="button" id="cmd-outdent" title="Decrease indent" style="font-size:15px;">&#8676;</button>
    <span class="sep"></span>

    <!-- Format block -->
    <select id="cmd-format" title="Text format">
      <option value="p">Normal</option>
      <option value="h1">Heading 1</option>
      <option value="h2">Heading 2</option>
      <option value="h3">Heading 3</option>
      <option value="blockquote">Quote</option>
      <option value="pre">Code</option>
    </select>
    <span class="sep"></span>

    <!-- Text color -->
    <div class="color-btn-wrap">
      <button type="button" id="cmd-text-color" title="Text color" style="font-weight:700;">A</button>
      <input type="color" id="text-color-picker" value="#000000">
    </div>
    <!-- Highlight color -->
    <div class="color-btn-wrap">
      <button type="button" id="cmd-bg-color" title="Highlight color" style="font-weight:700;text-decoration:underline;text-decoration-color:#FFFF00;text-underline-offset:2px;">A</button>
      <input type="color" id="bg-color-picker" value="#FFFF00">
    </div>
    <span class="sep"></span>

    <!-- Font family -->
    <select id="cmd-font-family" title="Font family">
      <option value="">Sans Serif</option>
      <option value="serif">Serif</option>
      <option value="monospace">Monospace</option>
      <option value="cursive">Cursive</option>
    </select>
    <span class="sep"></span>

    <!-- Alignment -->
    <button type="button" id="cmd-align-left" title="Align left" style="font-size:15px;">&#8801;</button>
    <button type="button" id="cmd-align-center" title="Align center" style="font-size:13px;letter-spacing:-1px;">=</button>
    <button type="button" id="cmd-align-right" title="Align right" style="font-size:15px;">&#8801;</button>
    <span class="sep"></span>

    <!-- Insert / Misc -->
    <button type="button" id="cmd-hr" title="Horizontal rule">&mdash;</button>
    <button type="button" id="cmd-clear-format" title="Clear formatting"><i>T</i><sub style="font-size:9px;">x</sub></button>
    <span class="sep"></span>

    <!-- Link / Image -->
    <button type="button" id="cmd-link" title="Insert link">&#128279;</button>
    <button type="button" id="cmd-image" title="Insert image">&#128444;</button>
  </div>

  <div id="editor" contenteditable="true" data-placeholder="Start typing..."></div>

  <script>
    (function() {
      var editor = document.getElementById("editor");

      /* ── Core helpers ── */
      function getHtml() { return editor.innerHTML || ""; }
      function setHtml(html) { editor.innerHTML = html || ""; }
      function sendToFlutter() {
        if (window.Editor && typeof window.Editor.postMessage === "function") {
          window.Editor.postMessage(getHtml());
        }
      }
      function exec(cmd, val) {
        document.execCommand(cmd, false, val || null);
        editor.focus();
        sendToFlutter();
      }

      window.__setEditorContent = function(html) { setHtml(html); };
      window.__getEditorContent = function() { return getHtml(); };

      /* ── Editor events ── */
      editor.addEventListener("input", sendToFlutter);
      editor.addEventListener("paste", function(e) {
        e.preventDefault();
        var html = (e.clipboardData || window.clipboardData).getData("text/html") ||
                   (e.clipboardData || window.clipboardData).getData("text/plain");
        document.execCommand("insertHTML", false, html || "");
        sendToFlutter();
      });

      /* ── Simple command buttons ── */
      var simpleCommands = {
        "cmd-bold": "bold",
        "cmd-italic": "italic",
        "cmd-underline": "underline",
        "cmd-strikethrough": "strikeThrough",
        "cmd-subscript": "subscript",
        "cmd-superscript": "superscript",
        "cmd-ul": "insertUnorderedList",
        "cmd-ol": "insertOrderedList",
        "cmd-indent": "indent",
        "cmd-outdent": "outdent",
        "cmd-align-left": "justifyLeft",
        "cmd-align-center": "justifyCenter",
        "cmd-align-right": "justifyRight",
        "cmd-hr": "insertHorizontalRule",
        "cmd-clear-format": "removeFormat"
      };
      Object.keys(simpleCommands).forEach(function(id) {
        var btn = document.getElementById(id);
        if (btn) btn.addEventListener("click", function() { exec(simpleCommands[id]); });
      });

      /* ── Headings (toggle) ── */
      document.getElementById("cmd-h1").addEventListener("click", function() {
        var current = document.queryCommandValue("formatBlock");
        exec("formatBlock", current === "h1" ? "p" : "h1");
      });
      document.getElementById("cmd-h2").addEventListener("click", function() {
        var current = document.queryCommandValue("formatBlock");
        exec("formatBlock", current === "h2" ? "p" : "h2");
      });

      /* ── Blockquote (toggle) ── */
      document.getElementById("cmd-blockquote").addEventListener("click", function() {
        var current = document.queryCommandValue("formatBlock");
        exec("formatBlock", current === "blockquote" ? "p" : "blockquote");
      });

      /* ── Format block dropdown ── */
      document.getElementById("cmd-format").addEventListener("change", function() {
        exec("formatBlock", this.value);
        this.blur();
      });

      /* ── Font family dropdown ── */
      document.getElementById("cmd-font-family").addEventListener("change", function() {
        if (this.value) {
          exec("fontName", this.value);
        } else {
          exec("fontName", "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif");
        }
        this.blur();
      });

      /* ── Text color ── */
      var textColorPicker = document.getElementById("text-color-picker");
      document.getElementById("cmd-text-color").addEventListener("click", function() {
        textColorPicker.click();
      });
      textColorPicker.addEventListener("input", function() {
        exec("foreColor", this.value);
      });

      /* ── Background / highlight color ── */
      var bgColorPicker = document.getElementById("bg-color-picker");
      document.getElementById("cmd-bg-color").addEventListener("click", function() {
        bgColorPicker.click();
      });
      bgColorPicker.addEventListener("input", function() {
        exec("hiliteColor", this.value);
      });

      /* ── Link ── */
      document.getElementById("cmd-link").addEventListener("click", function() {
        var url = prompt("Enter URL:", "https://");
        if (url) exec("createLink", url);
      });

      /* ── Image ── */
      document.getElementById("cmd-image").addEventListener("click", function() {
        var url = prompt("Enter image URL:", "https://");
        if (url) exec("insertImage", url);
      });
    })();
  </script>
</body>
</html>
''';
