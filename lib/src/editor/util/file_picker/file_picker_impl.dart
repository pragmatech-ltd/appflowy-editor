import 'dart:typed_data';

import 'package:appflowy_editor/src/editor/util/file_picker/file_picker_service.dart';
import 'package:file_picker/file_picker.dart' as fp;

class FilePicker implements FilePickerService {
  @override
  Future<String?> getDirectoryPath({String? title}) {
    return fp.FilePicker.getDirectoryPath();
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    Function(fp.FilePickerStatus p1)? onFileLoading,
    bool allowMultiple = false,
    bool lockParentWindow = false,
  }) async {
    final files = <fp.PlatformFile>[];
    if (allowMultiple) {
      final result = await fp.FilePicker.pickFiles(
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
        onFileLoading: onFileLoading,
        lockParentWindow: lockParentWindow,
      );
      files.addAll(result?.files ?? const []);
    } else {
      final file = await fp.FilePicker.pickFile(
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
        onFileLoading: onFileLoading,
        lockParentWindow: lockParentWindow,
      );
      if (file != null) {
        files.add(file);
      }
    }

    return FilePickerResult(files);
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    required String fileName,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    required Uint8List bytes,
    bool lockParentWindow = false,
  }) {
    return fp.FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      bytes: bytes,
      lockParentWindow: lockParentWindow,
    );
  }
}
