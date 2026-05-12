class CulturalSite {
  final int id;
  final String? name;
  final String? category;
  final String? district;
  final String? address;
  final String? shortDescription;
  final String? historicalSignificance;
  final String? culturalImportance;
  final double? entryFeeNPR;
  final double? entryFeeSAARC;
  final String? openingTime;
  final String? closingTime;
  final String? bestTimeToVisit;
  final bool isUNESCO;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CulturalSite({
    required this.id,
    this.name,
    this.category,
    this.district,
    this.address,
    this.shortDescription,
    this.historicalSignificance,
    this.culturalImportance,
    this.entryFeeNPR,
    this.entryFeeSAARC,
    this.openingTime,
    this.closingTime,
    this.bestTimeToVisit,
    required this.isUNESCO,
    required this.imageUrls,
    this.createdAt,
    this.updatedAt,
  });

  factory CulturalSite.fromJson(Map<String, dynamic> json) {
    return CulturalSite(
      id: json['id'] ?? 0,
      name: json['name'],
      category: json['category'],
      district: json['district'],
      address: json['address'],
      shortDescription: json['shortDescription'],
      historicalSignificance: json['historicalSignificance'],
      culturalImportance: json['culturalImportance'],
      entryFeeNPR: (json['entryFeeNPR'] as num?)?.toDouble(),
      entryFeeSAARC: (json['entryFeeSAARC'] as num?)?.toDouble(),
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      bestTimeToVisit: json['bestTimeToVisit'],
      isUNESCO: json['isUNESCO'] ?? false,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'district': district,
      'address': address,
      'shortDescription': shortDescription,
      'historicalSignificance': historicalSignificance,
      'culturalImportance': culturalImportance,
      'entryFeeNPR': entryFeeNPR,
      'entryFeeSAARC': entryFeeSAARC,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'bestTimeToVisit': bestTimeToVisit,
      'isUNESCO': isUNESCO,
      'imageUrls': imageUrls,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}