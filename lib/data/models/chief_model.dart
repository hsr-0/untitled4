class Chief {
  final int id;
  final String name;
  final String fullName;
  final String title;
  final String phone;
  final String? whatsapp;
  final String? imageUrl;
  late final int votersCount;
  late final List<Voter>? voters;

  Chief({
    required this.id,
    required this.name,
    required this.fullName,
    required this.title,
    required this.phone,
    this.whatsapp,
    this.imageUrl,
    required this.votersCount,
    this.voters,
  });

  factory Chief.fromJson(Map<String, dynamic> json) {
    return Chief(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      title: json['title'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      imageUrl: json['image'],
      votersCount: int.tryParse(json['voters_count'].toString()) ?? 0,
      voters: json['voters'] != null
          ? (json['voters'] as List).map((v) => Voter.fromJson(v)).toList()
          : null,
    );
  }
}
class Voter {
  final int id;
  final String name;
  final String fullName;
  final String phone;
  final String? cardImage;

  Voter({
    required this.id,
    required this.name,
    required this.fullName,
    required this.phone,
    this.cardImage,
  });

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      id: json['id'],
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      cardImage: json['card_image'],
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'full_name': fullName,
    'phone': phone,
    'card_image': cardImage,
  };
}