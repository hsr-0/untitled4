class Representation {
  final String id;
  final String title;
  final String? content;
  final String? thumbnail;
  final RepresentationLeader leader;
  final String location;
  final Office? office;
  final List<Region> regions;
  final int regionsCount;

  Representation({
    required this.id,
    required this.title,
    this.content,
    this.thumbnail,
    required this.leader,
    required this.location,
    this.office,
    required this.regions,
    required this.regionsCount,
  });

  factory Representation.fromJson(Map<String, dynamic> json) {
    return Representation(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'بدون عنوان',
      content: json['content']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      leader: RepresentationLeader.fromJson(json['leader'] ?? {}),
      location: json['location']?.toString() ?? 'غير محدد',
      office: json['office'] != null ? Office.fromJson(json['office']) : null,
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => Region.fromJson(e))
          .toList() ??
          [],
      regionsCount: json['regions_count'] ?? json['regionsCount'] ?? 0,
    );
  }
}

class RepresentationLeader {
  final String name;
  final String title;
  final String phone;
  final String whatsapp;
  final String? image;

  RepresentationLeader({
    required this.name,
    this.title = '',
    required this.phone,
    required this.whatsapp,
    this.image,
  });

  factory RepresentationLeader.fromJson(Map<String, dynamic> json) {
    return RepresentationLeader(
      name: json['name']?.toString() ?? 'غير معروف',
      title: json['title']?.toString() ?? '',
      phone: json['phone']?.toString() ?? 'غير متوفر',
      whatsapp: json['whatsapp']?.toString() ?? json['phone']?.toString() ?? 'غير متوفر',
      image: json['image']?.toString(),
    );
  }
}

class Region {
  final String id;
  final String name;
  final RegionLeader leader;

  Region({
    required this.id,
    required this.name,
    required this.leader,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'منطقة بدون اسم',
      leader: RegionLeader.fromJson(json['leader'] ?? {}),
    );
  }
}

class RegionLeader {
  final String name;
  final String phone;
  final String? image;

  RegionLeader({
    required this.name,
    required this.phone,
    this.image,
  });

  factory RegionLeader.fromJson(Map<String, dynamic> json) {
    return RegionLeader(
      name: json['name']?.toString() ?? 'غير معروف',
      phone: json['phone']?.toString() ?? 'غير متوفر',
      image: json['image']?.toString(),
    );
  }
}

class Office {
  final String id;
  final String title;
  final String leaderName;
  final String leaderPhone;
  final String location;

  Office({
    required this.id,
    required this.title,
    required this.leaderName,
    required this.leaderPhone,
    required this.location,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'مكتب بدون اسم',
      leaderName: json['leader_name']?.toString() ?? 'غير معروف',
      leaderPhone: json['leader_phone']?.toString() ?? 'غير متوفر',
      location: json['location']?.toString() ?? 'غير محدد',
    );
  }
}