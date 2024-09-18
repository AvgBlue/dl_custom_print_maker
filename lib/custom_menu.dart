import 'package:flutter/material.dart';
import 'character.dart';
import 'talisman.dart';
import 'ability.dart';

//TODO: to refactor the selection mentu

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
