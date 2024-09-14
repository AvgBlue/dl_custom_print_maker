// file_upload_button.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class FileUploadButton extends StatelessWidget {
  final void Function(String? fileName, String? fileContent) onFileSelected;

  const FileUploadButton({required this.onFileSelected, super.key});

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Specify JSON file type
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      String fileContent =
          String.fromCharCodes(file.bytes!); // Get file content

      onFileSelected(fileName, fileContent); // Pass both file name and content
    } else {
      onFileSelected('No file selected', null); // No file selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pickFile,
      child: const Text('Upload JSON File'),
    );
  }
}
