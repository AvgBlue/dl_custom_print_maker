import 'package:flutter/material.dart';

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

  Talisman createCopy(int talismanKeyId) {
    Talisman copy = Talisman.createTalisman(
      talismanKeyId,
      this.talismanId,
      this.talismanAbilityId1,
      this.talismanAbilityId2,
      this.talismanAbilityId3,
      this.additionalHp,
      this.additionalAttack,
    );
    return copy;
  }
}

//TODO: to rethink the name maybe have it call TalismanInfo
class TalismanWidget extends StatelessWidget {
  final Talisman? talisman;
  static List<dynamic>? characterData;
  static Map<String, dynamic>? abilityData;

  const TalismanWidget({super.key, required this.talisman});

  String? getTitleByTalismanId(int talismanId) {
    // Load the character data
    if (null == TalismanWidget.characterData) {
      return null;
    }

    // Find the character with the given talisman_id
    for (var character in TalismanWidget.characterData!) {
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
    if (null == TalismanWidget.abilityData) {
      return null;
    }
    if (0 == id) {
      return 'No ability in this slot';
    }
    // Convert the id to a string (since JSON keys are strings)
    String key = id.toString();
    // Check if the key exists and return the _Name property
    if (TalismanWidget.abilityData!.containsKey(key)) {
      return TalismanWidget.abilityData![key]['_Name'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? title;
    String? ability1Name;
    String? ability2Name;
    String? ability3Name;

    if (talisman != null) {
      title = getTitleByTalismanId(talisman!.talismanId);
      ability1Name = getNameById(talisman!.talismanAbilityId1);
      ability2Name = getNameById(talisman!.talismanAbilityId2);
      ability3Name = getNameById(talisman!.talismanAbilityId3);
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
