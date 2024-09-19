// file_upload_button.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FileUploadButton extends StatelessWidget {
  final void Function(
      String? fileName,
      String? fileContent,
      List<dynamic> characterData,
      Map<String, dynamic> abilityData) onFileSelected;

  const FileUploadButton({required this.onFileSelected, super.key});

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Specify JSON file type
    );
    List<dynamic> characterData = await loadCharacterData();
    Map<String, dynamic> abilityData = await loadAbilitiesData();

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      String fileContent =
          String.fromCharCodes(file.bytes!); // Get file content

      onFileSelected(fileName, fileContent, characterData,
          abilityData); // Pass both file name and content
    } else {
      onFileSelected('No file selected', null, characterData,
          abilityData); // No file selected
    }
  }

  Future<List<dynamic>> loadCharacterData() async {
    // Load the JSON file from the assets
    final jsonString =
        await rootBundle.loadString('character_data.json');

    // Parse the JSON string into a List of Maps
    List<dynamic> characterData = jsonDecode(jsonString);
    return characterData;
  }

  Future<Map<String, dynamic>> loadAbilitiesData() async {
    // Load the JSON file from the assets
    final jsonString =
        await rootBundle.loadString('abilitiesTextDescriptions5.json');
    // Parse the JSON string into a Map
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pickFile,
      child: const Text('Upload JSON File'),
    );
  }
}
