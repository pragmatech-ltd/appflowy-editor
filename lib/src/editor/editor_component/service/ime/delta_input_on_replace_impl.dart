import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/character_shortcut_event_helper.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/services.dart';

Future<void> onReplace(
  TextEditingDeltaReplacement replacement,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  AppFlowyEditorLog.input.debug('onReplace: $replacement');

  // delete the selection
  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  if (selection.isSingle) {
    final execution = await executeCharacterShortcutEvent(
      editorState,
      replacement.replacementText,
      characterShortcutEvents,
    );

    if (execution) {
      return;
    }

    if (PlatformExtension.isIOS) {
      // remove the trailing '\n' when pressing the return key
      if (replacement.replacementText.endsWith('\n')) {
        replacement = TextEditingDeltaReplacement(
          oldText: replacement.oldText,
          replacementText: replacement.replacementText
              .substring(0, replacement.replacementText.length - 1),
          replacedRange: replacement.replacedRange,
          selection: replacement.selection,
          composing: replacement.composing,
        );
      }
    }

    final node = editorState.getNodesInSelection(selection).first;
    final localReplacement = _localReplacementForNode(replacement, node);
    if (localReplacement == null) {
      AppFlowyEditorLog.input.debug(
        'skip invalid replacement range: $replacement for node ${node.path}',
      );
      return;
    }

    final transaction = editorState.transaction;
    final afterSelection = Selection(
      start: Position(
        path: node.path,
        offset: localReplacement.baseOffset,
      ),
      end: Position(
        path: node.path,
        offset: localReplacement.extentOffset,
      ),
    );
    transaction
      ..replaceText(
        node,
        localReplacement.start,
        localReplacement.length,
        replacement.replacementText,
      )
      ..afterSelection = afterSelection;
    await editorState.apply(transaction);
  } else {
    await editorState.deleteSelection(selection);
    // insert the replacement
    final insertion = replacement.toInsertion();
    await onInsert(
      insertion,
      editorState,
      characterShortcutEvents,
    );
  }
}

typedef _LocalReplacement = ({
  int start,
  int length,
  int baseOffset,
  int extentOffset,
});

_LocalReplacement? _localReplacementForNode(
  TextEditingDeltaReplacement replacement,
  Node node,
) {
  final delta = node.delta;
  if (delta == null) {
    return null;
  }

  final rangeStart = replacement.replacedRange.start;
  final rangeEnd = replacement.replacedRange.end;
  if (rangeStart < 0 || rangeEnd < rangeStart) {
    return null;
  }

  final nodeText = delta.toPlainText();
  final deltaLength = delta.length;
  final oldText = replacement.oldText;

  if (oldText.contains('\n')) {
    var lineStart = 0;
    for (final line in oldText.split('\n')) {
      final lineEnd = lineStart + line.length;
      final rangeFitsLine = rangeStart >= lineStart && rangeEnd <= lineEnd;
      final lineMatchesNode = line == nodeText || line.length == deltaLength;

      if (rangeFitsLine && lineMatchesNode) {
        return _replacementForLine(
          replacement,
          lineStart: lineStart,
          lineLength: line.length,
        );
      }

      lineStart = lineEnd + 1;
    }
  }

  if (rangeEnd > deltaLength) {
    return null;
  }

  return _replacementForLine(
    replacement,
    lineStart: 0,
    lineLength: deltaLength,
  );
}

_LocalReplacement _replacementForLine(
  TextEditingDeltaReplacement replacement, {
  required int lineStart,
  required int lineLength,
}) {
  final localStart = replacement.replacedRange.start - lineStart;
  final length = replacement.replacedRange.end - replacement.replacedRange.start;
  final updatedLength = lineLength - length + replacement.replacementText.length;

  return (
    start: localStart,
    length: length,
    baseOffset: _clampSelectionOffset(
      replacement.selection.baseOffset,
      lineStart,
      updatedLength,
    ),
    extentOffset: _clampSelectionOffset(
      replacement.selection.extentOffset,
      lineStart,
      updatedLength,
    ),
  );
}

int _clampSelectionOffset(int offset, int lineStart, int lineLength) {
  return (offset - lineStart).clamp(0, lineLength).toInt();
}

extension on TextEditingDeltaReplacement {
  TextEditingDeltaInsertion toInsertion() {
    final text = oldText.replaceRange(
      replacedRange.start,
      replacedRange.end,
      '',
    );

    return TextEditingDeltaInsertion(
      oldText: text,
      textInserted: replacementText,
      insertionOffset: replacedRange.start,
      selection: selection,
      composing: composing,
    );
  }
}
