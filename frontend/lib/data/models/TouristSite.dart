class TouristSite {
  final int id;
  final String name;
  final String category;
  final String district;
  final String address;
  final String shortDescription;
  final String historicalSignificance;
  final String culturalImportance;
  final double entryFeeNPR;
  final double entryFeeSAARC;
  final String openingTime;
  final String closingTime;
  final String bestTimeToVisit;
  final bool isUNESCO;
  final List<String> imageUrls;

  TouristSite({
    required this.id,
    required this.name,
    required this.category,
    required this.district,
    required this.address,
    required this.shortDescription,
    required this.historicalSignificance,
    required this.culturalImportance,
    required this.entryFeeNPR,
    required this.entryFeeSAARC,
    required this.openingTime,
    required this.closingTime,
    required this.bestTimeToVisit,
    required this.isUNESCO,
    required this.imageUrls,
  });

  factory TouristSite.fromJson(Map<String, dynamic> json) {
    return TouristSite(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      historicalSignificance: json['historicalSignificance'] ?? '',
      culturalImportance: json['culturalImportance'] ?? '',
      entryFeeNPR: (json['entryFeeNPR'] ?? 0).toDouble(),
      entryFeeSAARC: (json['entryFeeSAARC'] ?? 0).toDouble(),
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      isUNESCO: json['isUNESCO'] ?? false,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}