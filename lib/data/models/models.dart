// models.dart

/// نموذج يمثل مكتباً في النظام
class Office {
  final String id;
  final String title;
  final String? content;
  final String? thumbnail;
  final String location;
  final OfficeLeader leader;
  final List<Leader> leaders;
  final int leadersCount;
  final int totalMembers;

  Office({
    required this.id,
    required this.title,
    this.content,
    this.thumbnail,
    required this.location,
    required this.leader,
    required this.leaders,
    required this.leadersCount,
    required this.totalMembers,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: _parseString(json['id']),
      title: _parseString(json['title'], 'بدون عنوان'),
      content: json['content']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      location: _parseString(json['location'], 'غير محدد'),
      leader: OfficeLeader.fromJson(json),
      leaders: _parseList<Leader>(json['leaders'], (x) => Leader.fromJson(x)),
      leadersCount: _parseInt(json['leaders_count'] ?? json['leadersCount'] ?? 0),
      totalMembers: _parseInt(json['total_members'] ?? json['totalMembers'] ?? 0),
    );
  }
}

/// نموذج يمثل رئيس المكتب
class OfficeLeader {
  final String name;
  final String title;
  final String phone;
  final String? whatsapp;
  final String? image;

  OfficeLeader({
    required this.name,
    this.title = '',
    required this.phone,
    this.whatsapp,
    this.image,
  });

  factory OfficeLeader.fromJson(Map<String, dynamic> json) {
    return OfficeLeader(
      name: _parseString(json['leader_name'] ?? json['name'], 'غير معروف'),
      title: _parseString(json['leader_title'] ?? json['title'], ''),
      phone: _parseString(json['leader_phone'] ?? json['phone'], 'غير متوفر'),
      whatsapp: json['leader_whatsapp'] ?? json['whatsapp']?.toString(),
      image: json['leader_image']?.toString(),
    );
  }
}

/// نموذج يمثل رئيساً في النظام
class Leader {
  final String id;
  final String name;
  final String fullName;
  final String? title;
  final String phone;
  final String? whatsapp;
  final String? image;
  final String role;
  final List<Member> members;
  final int membersCount;

  Leader({
    required this.id,
    required this.name,
    required this.fullName,
    this.title,
    required this.phone,
    this.whatsapp,
    this.image,
    required this.role,
    required this.members,
    required this.membersCount,
  });

  factory Leader.fromJson(Map<String, dynamic> json) {
    return Leader(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      fullName: _parseString(json['full_name'] ?? json['fullName'], 'غير معروف'),
      title: json['title']?.toString(),
      phone: _parseString(json['phone'], 'غير متوفر'),
      whatsapp: json['whatsapp']?.toString(),
      image: json['image']?.toString(),
      role: _parseString(json['role'], 'main'),
      members: _parseList<Member>(json['members'], (x) => Member.fromJson(x)),
      membersCount: _parseInt(json['members_count'] ?? json['membersCount'] ?? 0),
    );
  }
}
class Member {
  final String id;
  final String name;
  final String fullName;
  final String phone;
  final String identity;
  final String joinDate;
  final String? whatsapp; // جديد
  final String? image; // جديد
  final Office? office;
  final Leader? leader;

  Member({
    required this.id,
    required this.name,
    required this.fullName,
    required this.phone,
    required this.identity,
    required this.joinDate,
    this.whatsapp, // جديد
    this.image, // جديد
    this.office,
    this.leader,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      fullName: _parseString(json['full_name'] ?? json['fullName'], 'عضو بدون اسم'),
      phone: _parseString(json['phone'], 'لا يوجد رقم'),
      identity: _parseString(json['identity'], ''),
      joinDate: _parseString(json['join_date'] ?? json['joinDate'], 'غير محدد'),
      whatsapp: _parseString(json['whatsapp'], null), // جديد
      image: _parseString(json['image'], null), // جديد
      office: json['office'] != null ? Office.fromJson(json['office']) : null,
      leader: json['leader'] != null ? Leader.fromJson(json['leader']) : null,
    );
  }

  static String _parseString(dynamic value, [String? defaultValue]) {
    if (value == null) return defaultValue ?? '';
    return value.toString();
  }
}

/// نموذج يمثل ممثلية في النظام
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
      id: _parseString(json['id']),
      title: _parseString(json['title'], 'بدون عنوان'),
      thumbnail: json['thumbnail']?.toString(),
      leader: RepresentationLeader.fromJson(json['leader'] ?? {}), // التعديل هنا
      location: _parseString(json['location'], 'غير محدد'),
      office: json['office'] != null ? Office.fromJson(json['office']) : null,
      regions: _parseList<Region>(json['regions'], (x) => Region.fromJson(x)),
      regionsCount: _parseInt(json['regions_count'] ?? json['regionsCount'] ?? 0),
    );
  }
}

/// نموذج يمثل رئيس الممثلية
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
      name: _parseString(json['representation_leader_name'] ?? json['leader_name'] ?? json['name'], 'غير معروف'),
      title: _parseString(json['representation_leader_title'] ?? json['leader_title'] ?? json['title'], ''),
      phone: _parseString(json['representation_leader_phone'] ?? json['leader_phone'] ?? json['phone'], 'غير متوفر'),
      whatsapp: _parseString(json['representation_leader_whatsapp'] ?? json['leader_whatsapp'] ?? json['whatsapp'], 'غير متوفر'),
      image: json['representation_leader_image']?.toString() ?? json['leader_image']?.toString() ?? json['image']?.toString(),
    );
  }
}

/// نموذج يمثل منطقة في النظام
class Region {
  final String id;
  final String name;
  final RegionLeader leader;
  final Representation? representation;
  final Office? office;

  Region({
    required this.id,
    required this.name,
    required this.leader,
    this.representation,
    this.office,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: _parseString(json['id']),
      name: _parseString(json['name'], 'منطقة بدون اسم'),
      leader: RegionLeader.fromJson(json),
      representation: json['representation'] != null ? Representation.fromJson(json['representation']) : null,
      office: json['office'] != null ? Office.fromJson(json['office']) : null,
    );
  }
}

/// نموذج يمثل مسؤول المنطقة
class RegionLeader {
  final String name;
  final String title;
  final String phone;
  final String whatsapp;
  final String? image;

  RegionLeader({
    required this.name,
    this.title = '',
    required this.phone,
    required this.whatsapp,
    this.image,
  });

  factory RegionLeader.fromJson(Map<String, dynamic> json) {
    return RegionLeader(
      name: _parseString(json['region_leader_name'] ?? json['leader_name'] ?? json['name'], 'غير معروف'),
      title: _parseString(json['region_leader_title'] ?? json['leader_title'] ?? json['title'], ''),
      phone: _parseString(json['region_leader_phone'] ?? json['leader_phone'] ?? json['phone'], 'غير متوفر'),
      whatsapp: _parseString(json['region_leader_whatsapp'] ?? json['leader_whatsapp'] ?? json['whatsapp'], 'غير متوفر'),
      image: json['region_leader_image']?.toString() ?? json['leader_image']?.toString() ?? json['image']?.toString(),
    );
  }
}

// ============ دوال مساعدة ============ //

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null || value == false) return defaultValue;
  return value.toString();
}

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}

List<T> _parseList<T>(dynamic list, T Function(dynamic) mapper) {
  if (list is! List) return [];
  try {
    return list.map(mapper).where((item) => item != null).cast<T>().toList();
  } catch (e) {
    return [];
  }
}