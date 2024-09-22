// file_upload_button.dart
import 'dart:io';

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
      String? fileContent;

      // Check if bytes is not null, else load from the file path
      if (file.bytes != null) {
        fileContent = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        // Read the file from its path
        final File localFile = File(file.path!);
        fileContent = await localFile.readAsString();
      } else {
        // Handle the case where neither bytes nor path is available
        fileContent = 'File content could not be loaded';
      }

      onFileSelected(fileName, fileContent, characterData, abilityData);
    } else {
      onFileSelected('No file selected', null, characterData, abilityData);
    }
  }

  Future<List<dynamic>> loadCharacterData() async {
    // Load the JSON file from the assets
    final jsonString =
        await rootBundle.loadString('assets/character_data.json');

    // Parse the JSON string into a List of Maps
    List<dynamic> characterData = jsonDecode(jsonString);
    return characterData;
  }

  Future<Map<String, dynamic>> loadAbilitiesData() async {
    // Load the JSON file from the assets
    final jsonString =
        await rootBundle.loadString('assets/abilitiesTextDescriptions5.json');
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
