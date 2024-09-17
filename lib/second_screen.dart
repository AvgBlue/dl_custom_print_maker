import 'package:flutter/material.dart';
import 'tlisman.dart';
import 'character.dart';
import 'dart:convert';
import 'ability.dart';

//TODO: to add a divaider
//TODO: to add the ability to add new wrymprint
//TODO: to add the ability to save the file

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
        //talismanList!.add(newTalisman);
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
                    print('Removing the talisman');
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

        // Optional: If you need to persist these changes back to the JSON or a file, handle it here.
        // For example:
        // widget.saveFileContent(jsonEncode(jsonData));
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
                  onDelete: onDelete(talisman),
                );
              },
            ),
          ),
          Expanded(
              child: EditBox(
            selectedTalisman: selectedTalisman,
            onSelectAbility: onSelectAbility,
            onSelectCharacter: onSelectCharacter,
          ))
        ],
      ),
    );
  }
}

class EditBox extends StatefulWidget {
  final Talisman? selectedTalisman;
  final void Function(int index, int value) onSelectAbility;
  final void Function(int value) onSelectCharacter;
  const EditBox(
      {super.key,
      required this.selectedTalisman,
      required this.onSelectAbility,
      required this.onSelectCharacter});

  @override
  State<EditBox> createState() => _EditBoxState();
}

class _EditBoxState extends State<EditBox> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromARGB(255, 134, 121, 120),
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
            SizedBox(height: 10),
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
                : const Text('Selecte a wyrmprint to edit'),
          ],
        ));
  }
}

class CharacterMenu extends StatefulWidget {
  final void Function(int value) onSelectCharacter;
  final Talisman? selectedTalisman;
  static List<Character>? characterList;

  const CharacterMenu(
      {super.key,
      required this.onSelectCharacter,
      required this.selectedTalisman});

  @override
  State<CharacterMenu> createState() => _CharacterMenuState();
}

class _CharacterMenuState extends State<CharacterMenu> {
  List<Character> filteredCharacters = [];
  String searchTerm = '';
  Character? selectedCharacter;

  @override
  void initState() {
    super.initState();
    filteredCharacters = CharacterMenu.characterList!;
    selectedCharacter = CharacterMenu.characterList!.firstWhere(
        (character) => character.id == widget.selectedTalisman!.talismanId);
  }

  void filterCharacters(String query) {
    setState(() {
      searchTerm = query.toLowerCase();
      filteredCharacters = CharacterMenu.characterList!.where((character) {
        return character.title.toLowerCase().contains(searchTerm) ||
            character.subtitle.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void selectCharacter(Character character) {
    setState(() {
      selectedCharacter = character;
      widget.onSelectCharacter(character.id);
      searchTerm = ''; // Clear the search term after selecting
      filteredCharacters =
          CharacterMenu.characterList!; // Reset the filtered list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: selectedCharacter != null
                  ? 'Selected: ${selectedCharacter!.title}'
                  : 'Search for character',
              border: const OutlineInputBorder(),
            ),
            onChanged: filterCharacters,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCharacters.length,
              itemBuilder: (context, index) {
                final character = filteredCharacters[index];
                return ListTile(
                  title: Text(character.title),
                  subtitle: Text(character.subtitle),
                  onTap: () {
                    selectCharacter(character); // Select character when tapped
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AbilityMenu extends StatefulWidget {
  final void Function(int index, int value) onSelectAbility;
  final Talisman? selectedTalisman;
  final int abilityIndex;
  static Map<int, Ability>? abilityMap;

  const AbilityMenu(
      {super.key,
      required this.selectedTalisman,
      required this.abilityIndex,
      required this.onSelectAbility});

  @override
  State<AbilityMenu> createState() => _AbilityMenuState();
}

class _AbilityMenuState extends State<AbilityMenu> {
  List<Ability> filteredAbilities = [];
  String searchTerm = '';
  Ability? selectedAbility;

  @override
  void initState() {
    super.initState();
    filteredAbilities = AbilityMenu.abilityMap!.values.toList();
    selectedAbility =
        AbilityMenu.abilityMap![widget.selectedTalisman![widget.abilityIndex]];
  }

  void filterAbilities(String query) {
    setState(() {
      searchTerm = query.toLowerCase();
      filteredAbilities = AbilityMenu.abilityMap!.values.where((ability) {
        return ability.name.toLowerCase().contains(searchTerm) ||
            ability.details.toLowerCase().contains(searchTerm) ||
            ability.belongsTo
                .any((item) => item.toLowerCase().contains(searchTerm));
      }).toList();
    });
  }

  void selectAbility(Ability ability) {
    setState(() {
      selectedAbility = ability;
      widget.onSelectAbility(widget.abilityIndex, selectedAbility!.id);
      searchTerm = ''; // Clear the search term after selecting
      filteredAbilities =
          AbilityMenu.abilityMap!.values.toList(); // Reset the filtered list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: selectedAbility != null
                  ? 'Selected: ${selectedAbility!.name}'
                  : 'Search for ability',
              border: const OutlineInputBorder(),
            ),
            onChanged: filterAbilities,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAbilities.length,
              itemBuilder: (context, index) {
                final ability = filteredAbilities[index];
                return ListTile(
                  title: Text(ability.name),
                  subtitle: Text(
                    ability.details.replaceAll('\\n', '\n'),
                  ),
                  onTap: () {
                    selectAbility(ability); // Select ability when tapped
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
