import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/er/sharer.dart';

void main() {
  testWidgets(
    'uses tapped widget render box when available',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(key: key, width: 140, height: 56),
            ),
          ),
        ),
      );

      final context = key.currentContext!;
      final box = context.findRenderObject() as RenderBox;
      final expectedRect = box.localToGlobal(Offset.zero) & box.size;
      final rect = Sharer.resolveSharePositionOrigin(context);
      expect(rect, expectedRect);
    },
  );
}
