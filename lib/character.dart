class Character {
  final String title;
  final String subtitle;
  final int id;

  Character({
    required this.title,
    required this.subtitle,
    required this.id,
  });

  // Factory constructor to create the object from a JSON map
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      title: json['title'],
      subtitle: json['subtitle'],
      id: int.parse(json['talisman_id']), // Convert the talisman_id to int
    );
  }
}
