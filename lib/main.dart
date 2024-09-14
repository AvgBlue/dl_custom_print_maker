import 'package:flutter/material.dart';
import 'second_screen.dart';
import 'file_upload_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
  void updateFileName(String? name, String? content) {
    setState(() {
      if (name != null && content != null) {
        String fileName = name;
        String fileContent = content;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(
              fileName: fileName,
              fileContent: fileContent,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dragalia Lost Print Maker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FileUploadButton(onFileSelected: updateFileName),
          ],
        ),
      ),
    );
  }
}
