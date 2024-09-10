import 'package:flutter/material.dart';
import 'file_upload_button.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Upload Example',
      home: FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? fileName;
  String? fileContent;

  void updateFileName(String? name, String? content) {
    setState(() {
      fileName = name;
      fileContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FileUploadButton(onFileSelected: updateFileName),
            SizedBox(height: 20),
            if (fileName != null) Text('Selected File: $fileName'),
          ],
        ),
      ),
    );
  }
}
