import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_magnifier.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../test_helper.dart';

void main() {
  group('MobileSelectionServiceWidget', () {
    testWidgets('can render', (tester) async {
      final document = Document.blank();
      final editorState = EditorState(document: document);

      await tester.buildAndPump(
        Provider(
          create: (context) => editorState,
          child: const MobileSelectionServiceWidget(
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobileSelectionServiceWidget), findsOneWidget);
    });

    testWidgets('positions the magnifier well above the touch point', (
      tester,
    ) async {
      const touchOffset = Offset(120, 200);
      const magnifierSize = Size(144, 96);
      const focalPointOffsetFromBottom = 8.0;

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              children: [
                MobileMagnifier(
                  size: magnifierSize,
                  offset: touchOffset,
                  focalPointOffsetFromBottom: focalPointOffsetFromBottom,
                ),
              ],
            ),
          ),
        ),
      );

      final magnifierRect = tester.getRect(find.byType(RawMagnifier));
      expect(magnifierRect.bottom, moreOrLessEquals(160, epsilon: 0.1));
      expect(
        touchOffset.dy - magnifierRect.bottom,
        moreOrLessEquals(40, epsilon: 0.1),
      );
    });
  });
}
