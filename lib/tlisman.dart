import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Talisman {
  int talismanKeyId;
  int talismanId;
  int isLock;
  int isNew;
  int talismanAbilityId1;
  int talismanAbilityId2;
  int talismanAbilityId3;
  int additionalHp;
  int additionalAttack;
  int gettime;

  Talisman({
    required this.talismanKeyId,
    required this.talismanId,
    required this.isLock,
    required this.isNew,
    required this.talismanAbilityId1,
    required this.talismanAbilityId2,
    required this.talismanAbilityId3,
    required this.additionalHp,
    required this.additionalAttack,
    required this.gettime,
  });

  factory Talisman.fromJson(Map<String, dynamic> json) {
    return Talisman(
      talismanKeyId: json['talisman_key_id'],
      talismanId: json['talisman_id'],
      isLock: json['is_lock'],
      isNew: json['is_new'],
      talismanAbilityId1: json['talisman_ability_id_1'],
      talismanAbilityId2: json['talisman_ability_id_2'],
      talismanAbilityId3: json['talisman_ability_id_3'],
      additionalHp: json['additional_hp'],
      additionalAttack: json['additional_attack'],
      gettime: json['gettime'],
    );
  }

  static Talisman createTalisman(
    int keyId,
    int talismanId,
    int abilityId1,
    int abilityId2,
    int abilityId3,
    int additionalHp,
    int additionalAttack,
  ) {
    int gettime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Talisman(
      talismanKeyId: keyId,
      talismanId: talismanId,
      isLock: 0, // Default value
      isNew: 1, // Default value
      talismanAbilityId1: abilityId1,
      talismanAbilityId2: abilityId2,
      talismanAbilityId3: abilityId3,
      additionalHp: additionalHp,
      additionalAttack: additionalAttack,
      gettime: gettime,
    );
  }
}

class TalismanWidget extends StatefulWidget {
  final Talisman talisman;

  const TalismanWidget({super.key, required this.talisman});

  @override
  State<TalismanWidget> createState() => _TalismanWidgetState();
}

class _TalismanWidgetState extends State<TalismanWidget> {
  String? title;
  String? ability1Name;
  String? ability2Name;
  String? ability3Name;

  static List<dynamic>? characterData;
  static Map<String, dynamic>? abilityData;

  Future<List<dynamic>> loadCharacterData() async {
    // Load the JSON file from the assets
    final jsonString = await rootBundle.loadString('res/character_data.json');

    // Parse the JSON string into a List of Maps
    List<dynamic> characterData = jsonDecode(jsonString);
    return characterData;
  }

  Future<Map<String, dynamic>> loadAbilitiesData() async {
    // Load the JSON file from the assets
    final jsonString =
        await rootBundle.loadString('res/abilitiesTextDescriptions.json');
    // Parse the JSON string into a Map
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap;
  }

  String? getTitleByTalismanId(int talismanId) {
    // Load the character data
    if (null == characterData) {
      return null;
    }

    // Find the character with the given talisman_id
    for (var character in characterData!) {
      // Convert talisman_id from string to int for comparison
      int characterTalismanId = int.parse(character['talisman_id']);
      if (characterTalismanId == talismanId) {
        return character['title'];
      }
    }
    return null;
  }

  String? getNameById(int id) {
    // Load the abilities data
    if (null == abilityData) {
      return null;
    }
    if (0 == id) {
      return 'No ability in this slot';
    }
    // Convert the id to a string (since JSON keys are strings)
    String key = id.toString();
    // Check if the key exists and return the _Name property
    if (abilityData!.containsKey(key)) {
      return abilityData![key]['_Name'];
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (null == characterData) {
      loadCharacterData().then((value) {
        setState(() {
          characterData = value;
          title = getTitleByTalismanId(widget.talisman.talismanId);
        });
      });
    } else {
      title = getTitleByTalismanId(widget.talisman.talismanId);
    }
    if (null == abilityData) {
      loadAbilitiesData().then((value) {
        setState(() {
          abilityData = value;
          ability1Name = getNameById(widget.talisman.talismanAbilityId1);
          ability2Name = getNameById(widget.talisman.talismanAbilityId2);
          ability3Name = getNameById(widget.talisman.talismanAbilityId3);
        });
      });
    } else {
      ability1Name = getNameById(widget.talisman.talismanAbilityId1);
      ability2Name = getNameById(widget.talisman.talismanAbilityId2);
      ability3Name = getNameById(widget.talisman.talismanAbilityId3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85, // Adjust height as needed
      width: 400,
      color: const Color.fromARGB(240, 2, 205, 219),
      child: Column(
        // Changed from Row to Column
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns the text to the start (left)
        children: [
          Text('Character: ${title ?? 'unknown'}'),
          Text('Ability 1: ${ability1Name ?? 'unknown'}'),
          Text('Ability 2: ${ability2Name ?? 'unknown'}'),
          Text('Ability 3: ${ability3Name ?? 'unknown'}'),
        ],
      ),
    );
  }
}
