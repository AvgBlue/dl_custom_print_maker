class Ability {
  final int id;
  final String name;
  final String details;
  final List<String> belongsTo;

  Ability({
    required this.id,
    required this.name,
    required this.details,
    required this.belongsTo,
  });

  // Factory constructor to create the object from a JSON map
  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      id: json['_Id'],
      name: json['_Name'],
      details: json['_Details'],
      belongsTo: json.containsKey('BelongsTo')
          ? List<String>.from(json['BelongsTo'])
          : [], // Empty array if 'BelongsTo' is missing
    );
  }
}
