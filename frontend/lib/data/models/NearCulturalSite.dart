class NearCulturalSite {
  final int id;
  final String name;

  NearCulturalSite({
    required this.id,
    required this.name,
  });

  factory NearCulturalSite.fromJson(Map<String, dynamic> json) {
    return NearCulturalSite(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}