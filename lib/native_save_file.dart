import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveFileNative(String fileName, String content) async {
  // Ask the user to select a directory where the file should be saved
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    // Create the file in the selected directory
    final path = '$selectedDirectory/$fileName';
    final file = File(path);
    await file.writeAsString(content);

    print('File saved at: $path');
  } else {
    print('No directory selected.');
  }
}

void saveFileWeb(String fileName, String fileType, String content) {
  throw UnsupportedError("Cannot save files on this platform");
}
