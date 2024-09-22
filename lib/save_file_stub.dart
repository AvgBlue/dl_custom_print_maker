void saveFileWeb(String fileName, String fileType, String content) {
  throw UnsupportedError("Cannot save files on this platform");
}

Future<void> saveFileNative(String fileName, String content) async {
  throw UnsupportedError("Cannot save files on this platform");
}
