// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveFileWeb(String fileName, String fileType, String content) {
  final blob = html.Blob([content], fileType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> saveFileNative(String fileName, String content) async {
  throw UnsupportedError("Cannot save files on this platform");
}
