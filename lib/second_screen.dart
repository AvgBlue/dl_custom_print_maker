import 'package:flutter/material.dart';
import 'tlisman.dart';
import 'dart:convert';

//todo: add an edit screen 
// todo: to add an edit buttons

class SecondScreen extends StatefulWidget {
  final String fileName;
  final String fileContent;

  const SecondScreen(
      {super.key, required this.fileName, required this.fileContent});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<Talisman>? talismanList;

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic> jsonData = jsonDecode(widget.fileContent);
    if (jsonData.containsKey('data') &&
        jsonData['data'].containsKey('talisman_list')) {
      List<dynamic> talismanListJson = jsonData['data']['talisman_list'];
      setState(() {
        talismanList = talismanListJson.map((json) {
          return Talisman.fromJson(json as Map<String, dynamic>);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: talismanList?.length ?? 0,
              itemBuilder: (context, index) {
                Talisman talisman = talismanList![index];
                return TalismanWidget(talisman: talisman);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Button pressed!');
        },
        child: Icon(Icons.add),
        tooltip: 'Add',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
