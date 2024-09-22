import 'package:flutter/material.dart';
import 'second_screen.dart';
import 'file_upload_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'dart:typed_data';

//{0:"<No Attunement>",1:"Flame",2:"Water",3:"Wind",4:"Light",5:"Shadow",98:"<Portrait Dependent Elemental>"}
//{0:"<No Type>",1:"Sword",2:"Blade",3:"Dagger",4:"Axe",5:"Lance",6:"Bow",7:"Wand",8:"Staff",9:"Manacaster", 98: "<Portrait Dependent Weapon>"}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    const ColorScheme customColorScheme = ColorScheme(
      brightness:
          Brightness.light, // You can change this to Brightness.dark if needed
      primary: Color(0xFF5465FF), // Primary color
      onPrimary: Colors.white, // Text color on primary color
      secondary: Color(0xFF788BFF), // Secondary color
      onSecondary: Colors.white, // Text color on secondary color
      surface: Color(0xFFBFD7FF), // Surface color (for cards, etc.)
      onSurface: Colors.black, // Text color on surface
      error: Colors.red, // Default error color
      onError: Colors.white, // Text color on error
    );

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: customColorScheme, // Apply the custom color scheme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Customize as needed
      ),
    );

    return MaterialApp(
      title: 'Dragalia Lost Print Maker',
      theme: theme,
      home: const FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

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
        backgroundColor: Color(0xFFE2FDFF),
        title: const Text('Dragalia Lost Print Maker'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/mainbackground.jpg'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FileUploadButton(onFileSelected: updateFileName),
            ],
          ),
        ),
      ),
    );
  }
}

// don't work and not in use
class OrchisSaveDownloader extends StatefulWidget {
  const OrchisSaveDownloader({super.key});

  @override
  State<OrchisSaveDownloader> createState() => _OrchisSaveDownloaderState();
}

class _OrchisSaveDownloaderState extends State<OrchisSaveDownloader> {
  final TextEditingController _controller = TextEditingController();

  Future<String?> sendGetRequest(String id) async {
    // Construct the URL by adding the ID
    final url =
        Uri.parse('https://orchis.cherrymint.live/savedata.json?id=$id');

    try {
      // Send the GET request
      final response = await http.get(url);

      // Check if the status code is 200 (success)
      if (response.statusCode == 200) {
        // Check if the content type is MessagePack
        if (response.headers['content-type'] == 'application/msgpack') {
          // Decode the MessagePack response
          Uint8List binaryData = response.bodyBytes; // Get binary data
          final unpackedData =
              deserialize(binaryData); // Deserialize MessagePack data

          // Convert the unpacked data to JSON string (or handle it as needed)
          String jsonString = jsonEncode(unpackedData);
          print('Response (Decoded MessagePack): $jsonString');
          return jsonString;
        } else {
          // If the response is JSON or any other format, handle it as JSON
          final jsonResponse = jsonDecode(response.body);
          print('Response (JSON): $jsonResponse');
          return jsonEncode(jsonResponse); // Return JSON as a string
        }
      } else {
        // Print the error response for non-200 status codes
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body (Text): ${response.body}');
      }
    } catch (error) {
      // Handle any errors that might occur
      print('An error occurred: $error');
    }
    return null;
  }

  void onPressed(String input) {
    sendGetRequest(input).then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Savefile From Orchis'),
        SizedBox(
          width: 200,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Account ID',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onPressed(_controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
