import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_flutter/rich_text_flutter.dart';

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
