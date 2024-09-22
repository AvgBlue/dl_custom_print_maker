import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveFileNative(String fileName, String content) async {
  if (Platform.isAndroid || Platform.isIOS) {
    // Request storage permissions
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Get the directory to save the file
  Directory? directory = await getDownloadsDirectory();
  if (directory != null) {
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(content);

    print('File saved at: $path');
  }
}

void saveFileWeb(String fileName, String fileType, String content) {
  throw UnsupportedError("Cannot save files on this platform");
}