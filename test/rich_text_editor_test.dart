import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_flutter/rich_text_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  group('RichTextEditorController', () {
    test('pendingHtml returns initialHtml when not attached', () {
      final c = RichTextEditorController(initialHtml: '<p>Hi</p>');
      expect(c.pendingHtml, '<p>Hi</p>');
      expect(c.isReady, false);
    });

    test('pendingHtml is null when no initial HTML', () {
      final c = RichTextEditorController();
      expect(c.pendingHtml, isNull);
    });

    test('setHtml before attach stores pending', () {
      final c = RichTextEditorController();
      c.setHtml('<p>Later</p>');
      expect(c.pendingHtml, '<p>Later</p>');
    });
  });

  group('RichTextEditor', () {
    testWidgets('builds without exploding', (tester) async {
      // WebView requires a platform implementation (Android, iOS, Web, etc.).
      // In the test VM none is registered; set a fake so the widget can build.
      final previous = WebViewPlatform.instance;
      WebViewPlatform.instance = FakeWebViewPlatform();
      addTearDown(() {
        if (previous != null) {
          WebViewPlatform.instance = previous;
        }
      });

      final controller = RichTextEditorController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextEditor(controller: controller),
          ),
        ),
      );
      expect(find.byType(RichTextEditor), findsOneWidget);
    });
  });
}

/// Fake [WebViewPlatform] for tests (no real WebView in VM).
class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakePlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return FakePlatformWebViewCookieManager(params);
  }
}

class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async => '';
}

class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(
      PlatformNavigationDelegateCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback onSslAuthError) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}
}

class FakePlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  FakePlatformWebViewCookieManager(
      PlatformWebViewCookieManagerCreationParams params)
      : super.implementation(params);
}
