import 'package:flutter/material.dart';
import 'second_screen.dart';
import 'file_upload_button.dart';

//{0:"<No Attunement>",1:"Flame",2:"Water",3:"Wind",4:"Light",5:"Shadow",98:"<Portrait Dependent Elemental>"}
//{0:"<No Type>",1:"Sword",2:"Blade",3:"Dagger",4:"Axe",5:"Lance",6:"Bow",7:"Wand",8:"Staff",9:"Manacaster", 98: "<Portrait Dependent Weapon>"}
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
  // TODO: to refactor names
  void updateFileName(String? name, String? content,
      List<dynamic>? characterData, Map<String, dynamic>? abilityData) {
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
              characterData: characterData,
              abilityData: abilityData,
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
