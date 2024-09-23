import 'package:flutter/material.dart';
import 'talisman.dart';
import 'character.dart';
import 'dart:convert';
import 'ability.dart';
import 'custom_menu.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'save_file_stub.dart'
    if (dart.library.html) 'web_save_file.dart'
    if (dart.library.io) 'native_save_file.dart';

//TODO: to add a divaider

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
  List<Map<String, dynamic>>? partyList;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jsonData = jsonDecode(widget.fileContent);

    if (jsonData.containsKey('data') &&
        jsonData['data'].containsKey('party_list')) {
      List<dynamic> partyListDynamic = jsonData['data']['party_list'];
      setState(() {
        partyList = partyListDynamic
            .map((item) => item as Map<String, dynamic>)
            .toList();
      });
    }

    TalismanWidget.characterData = widget.characterData;
    TalismanWidget.abilityData = widget.abilityData;

    // load the save file talismans
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
    // Set the AbilityMap for AbilityMenu
    AbilityMenu.abilityMap = widget.abilityData!.map((key, value) {
      return MapEntry(int.parse(key), Ability.fromJson(value));
    });
    AbilityMenu.abilityMap![0] =
        Ability(id: 0, name: '<No Ability>', details: '', belongsTo: []);
    CharacterMenu.characterList = widget.characterData!
        .map((json) => Character.fromJson(json as Map<String, dynamic>))
        .toList();
    CharacterMenu.characterList!.sort((a, b) => a.title.compareTo(b.title));
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
        // Find the index of the talisman being copied
        int originalIndex = talismanList!.indexOf(talisman);

        // Insert the new talisman right after the original
        talismanList!.insert(originalIndex + 1, newTalisman);
      });
    };
  }

  void Function() onDelete(Talisman talisman) {
    return () {
      setState(() {
        // 1. Remove the talisman from the talismanList
        talismanList?.remove(talisman);

        // 2. Iterate through each party in the partyList
        if (partyList != null) {
          for (var party in partyList!) {
            if (party.containsKey('party_setting_list')) {
              List<dynamic> units = party['party_setting_list'];

              // Iterate through each unit in the party_setting_list
              for (var unit in units) {
                if (unit is Map<String, dynamic>) {
                  // Check if the unit has the 'equip_talisman_key_id' and if it matches the talisman to be deleted
                  if (unit['equip_talisman_key_id'] == talisman.talismanKeyId) {
                    // Remove the talisman by setting the key to 0 or any default value you prefer
                    unit['equip_talisman_key_id'] = 0;
                  }
                }
              }
            }
          }
        }

        // Optional: Update maxKeyId if necessary
        if (talismanList != null && talismanList!.isNotEmpty) {
          maxKeyId = talismanList!
              .map((t) => t.talismanKeyId)
              .reduce((a, b) => a > b ? a : b);
        } else {
          maxKeyId = 0;
        }
      });
    };
  }

  void onSelectAbility(int index, int value) {
    setState(() {
      selectedTalisman![index] = value;
    });
  }

  void onSelectCharacter(int value) {
    setState(() {
      selectedTalisman!.talismanId = value;
    });
  }

  void onChangeHP(String value) {
    setState(() {
      int? attackValue = int.tryParse(value);
      if (attackValue != null) {
        selectedTalisman!.additionalHp = attackValue;
      }
    });
  }

  void onChangeAttack(String value) {
    setState(() {
      int? attackValue = int.tryParse(value);
      if (attackValue != null) {
        selectedTalisman!.additionalAttack = attackValue;
      }
    });
  }

  void saveFile() {
    final String newFileName = 'modified_${widget.fileName}';
    Map<String, dynamic> jsonData = jsonDecode(widget.fileContent);

    // Update talisman_list and party_list
    if (jsonData.containsKey('data')) {
      if (talismanList != null) {
        jsonData['data']['talisman_list'] =
            talismanList!.map((talisman) => talisman.toJson()).toList();
      }
      if (partyList != null) {
        jsonData['data']['party_list'] = partyList;
      }
    }

    String newFileContent =
        const JsonEncoder.withIndent('  ').convert(jsonData);

    // Check if running on web or native platform
    if (kIsWeb) {
      saveFileWeb(newFileName, 'application/json', newFileContent);
    } else {
      saveFileNative(newFileName, newFileContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE2FDFF),
        title: const Text('Savefile Edit screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveFile,
            tooltip: 'save the modified savefile',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/editscreen.jpg'), fit: BoxFit.cover),
        ),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: talismanList?.length ?? 0,
                itemBuilder: (context, index) {
                  Talisman talisman =
                      talismanList![talismanList!.length - index - 1];
                  return TalismanContainer(
                    talisman: talisman,
                    onEdit: onEdit(talisman),
                    onCopy: onCopy(talisman),
                    onDelete: onDelete(talisman),
                  );
                },
              ),
            ),
            Expanded(
              child: Card(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  child: EditBox(
                    selectedTalisman: selectedTalisman,
                    onSelectAbility: onSelectAbility,
                    onSelectCharacter: onSelectCharacter,
                    onChangeHP: onChangeHP,
                    onChangeAttack: onChangeAttack,
                  )),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            int newKeyId = maxKeyId + 100;
            Talisman newTalisman =
                Talisman.createTalisman(newKeyId, 50140101, 0, 0, 0, 0, 0);
            maxKeyId = newKeyId;
            talismanList!.add(newTalisman);
          });
        },
      ),
    );
  }
}

class EditBox extends StatefulWidget {
  final Talisman? selectedTalisman;
  final void Function(int index, int value) onSelectAbility;
  final void Function(int value) onSelectCharacter;
  final void Function(String value) onChangeHP;
  final void Function(String value) onChangeAttack;

  const EditBox(
      {super.key,
      required this.selectedTalisman,
      required this.onSelectAbility,
      required this.onSelectCharacter,
      required this.onChangeHP,
      required this.onChangeAttack});

  @override
  State<EditBox> createState() => _EditBoxState();
}

class _EditBoxState extends State<EditBox> {
  int _selectedIndex = 0;
  late TextEditingController _hpController = TextEditingController();
  late TextEditingController _attackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hpController = TextEditingController(
        text: widget.selectedTalisman?.additionalHp.toString() ?? '');
    _attackController = TextEditingController(
        text: widget.selectedTalisman?.additionalAttack.toString() ?? '');
  }

  @override
  @override
  void didUpdateWidget(EditBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTalisman != oldWidget.selectedTalisman) {
      _hpController!.text =
          widget.selectedTalisman?.additionalHp.toString() ?? '';
      _attackController!.text =
          widget.selectedTalisman?.additionalAttack.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _hpController.dispose();
    _attackController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        TalismanWidget(talisman: widget.selectedTalisman),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _hpController,
                decoration: InputDecoration(
                  labelText:
                      'HP: ${widget.selectedTalisman?.additionalHp ?? ''}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.onChangeHP(value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _attackController,
                decoration: InputDecoration(
                  labelText:
                      'Strength: ${widget.selectedTalisman?.additionalAttack ?? ''}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.onChangeAttack(value);
                },
              ),
            ),
          ],
        ),
        NavigationBar(
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.3),
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
        const SizedBox(height: 10),
        (widget.selectedTalisman != null)
            ? <Widget>[
                CharacterMenu(
                  onSelectCharacter: widget.onSelectCharacter,
                  selectedTalisman: widget.selectedTalisman,
                ),
                AbilityMenu(
                  onSelectAbility: widget.onSelectAbility,
                  abilityIndex: 1,
                  selectedTalisman: widget.selectedTalisman,
                ),
                AbilityMenu(
                  onSelectAbility: widget.onSelectAbility,
                  abilityIndex: 2,
                  selectedTalisman: widget.selectedTalisman,
                ),
                AbilityMenu(
                  onSelectAbility: widget.onSelectAbility,
                  abilityIndex: 3,
                  selectedTalisman: widget.selectedTalisman,
                ),
              ][_selectedIndex]
            : const Text('Select a wyrmprint to edit'),
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
    return Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
          ),
        ));
  }
}
