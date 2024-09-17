import 'package:flutter/material.dart';
import 'tlisman.dart';
import 'dart:convert';

//TODO: add edit fucntionality to the edit screen
//TODO: to add the functioality to the delete button

class SecondScreen extends StatefulWidget {
  final String fileName;
  final String fileContent;
  final List<dynamic>? characterData;
  final Map<String, dynamic>? abilityData;

  SecondScreen(
      {super.key,
      required this.fileName,
      required this.fileContent,
      required this.characterData,
      required this.abilityData}) {
    TalismanWidget.characterData = characterData;
    TalismanWidget.abilityData = abilityData;
  }

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<Talisman>? talismanList;
  Talisman? selectedTalisman;
  int maxKeyId = 0;

  @override
  void initState() {
    super.initState();
    TalismanWidget.characterData = widget.characterData;
    TalismanWidget.abilityData = widget.abilityData;
    // load the save file talismans
    final Map<String, dynamic> jsonData = jsonDecode(widget.fileContent);
    if (jsonData.containsKey('data') &&
        jsonData['data'].containsKey('talisman_list')) {
      List<dynamic> talismanListJson = jsonData['data']['talisman_list'];
      setState(() {
        talismanList = talismanListJson.map((json) {
          return Talisman.fromJson(json as Map<String, dynamic>);
        }).toList();
        maxKeyId = talismanList!.fold(
            0,
            (int max, talisman) =>
                talisman.talismanKeyId > max ? talisman.talismanKeyId : max);
      });
    }
  }

  void Function() onEdit(Talisman talisman) {
    return () {
      setState(() {
        selectedTalisman = talisman;
      });
    };
  }

  void Function() onCopy(Talisman talisman) {
    return () {
      setState(() {
        int newKeyId = maxKeyId + 100;
        Talisman newTalisman = talisman.createCopy(newKeyId);
        maxKeyId = newKeyId;
        //talismanList!.add(newTalisman);
        // Find the index of the talisman being copied
        int originalIndex = talismanList!.indexOf(talisman);

        // Insert the new talisman right after the original
        talismanList!.insert(originalIndex + 1, newTalisman);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Talisman>? list = talismanList?.reversed.toList();
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
                Talisman talisman = list![index];
                return TalismanContainer(
                  talisman: talisman,
                  onEdit: onEdit(talisman),
                  onCopy: onCopy(talisman),
                  onDelete: () => print('delete'),
                );
              },
            ),
          ),
          Expanded(
              child: editBox(
            selectedTalisman: selectedTalisman,
          ))
        ],
      ),
    );
  }
}

class editBox extends StatefulWidget {
  final Talisman? selectedTalisman;
  const editBox({super.key, required this.selectedTalisman});

  @override
  State<editBox> createState() => _editBoxState();
}

class _editBoxState extends State<editBox> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.red,
        child: Column(
          children: [
            TalismanWidget(talisman: widget.selectedTalisman),
            NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Character',
                ),
                NavigationDestination(
                  icon: Icon(Icons.looks_one),
                  label: 'Ability 1',
                ),
                NavigationDestination(
                  icon: Icon(Icons.looks_two),
                  label: 'Ability 2',
                ),
                NavigationDestination(
                  icon: Icon(Icons.looks_3),
                  label: 'Ability 3',
                ),
              ],
            ),
            <Widget>[
              Text(widget.selectedTalisman?.talismanId?.toString() ?? ''),
              Text(widget.selectedTalisman?.talismanAbilityId1?.toString() ??
                  ''),
              Text(widget.selectedTalisman?.talismanAbilityId2?.toString() ??
                  ''),
              Text(widget.selectedTalisman?.talismanAbilityId3?.toString() ??
                  ''),
            ][_selectedIndex],
          ],
        ));
  }
}

class TalismanContainer extends StatefulWidget {
  final Talisman talisman;
  final void Function() onEdit;
  final void Function() onCopy;
  final void Function() onDelete;

  const TalismanContainer(
      {super.key,
      required this.talisman,
      required this.onEdit,
      required this.onCopy,
      required this.onDelete});

  @override
  State<TalismanContainer> createState() => _TalismanContainerState();
}

class _TalismanContainerState extends State<TalismanContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        //height: 200, // Adjust height as needed
        width: 400,
        color: const Color.fromARGB(240, 2, 205, 219),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TalismanWidget(talisman: widget.talisman),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: widget.onCopy,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            )
          ],
        ));
  }
}
