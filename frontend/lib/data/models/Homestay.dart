class Homestay {
  final int id;
  final String name;
  final String location;
  final String description;
  final String? category;
  final double pricePerNight;
  final List<String> imageUrls;
  final bool isVisible;

  // Cultural / heritage fields
  final String? buildingHistory;
  final String? culturalSignificance;
  final String? traditionalFeatures;
  final List<String> culturalExperiences;

  // Capacity
  final int numberOfRooms;
  final int maxGuests;
  final int bathrooms;

  // Amenities
  final List<String> amenities;

  // Near cultural site (nested object from API)
  final NearCulturalSite? nearCulturalSite;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Homestay({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    this.category,
    required this.pricePerNight,
    required this.imageUrls,
    required this.isVisible,
    this.buildingHistory,
    this.culturalSignificance,
    this.traditionalFeatures,
    this.culturalExperiences = const [],
    this.numberOfRooms = 0,
    this.maxGuests = 0,
    this.bathrooms = 0,
    this.amenities = const [],
    this.nearCulturalSite,
    this.createdAt,
    this.updatedAt,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString(),
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      imageUrls: _parseStringList(json['imageUrls']),
      isVisible: json['isVisible'] as bool? ?? false,
      buildingHistory: json['buildingHistory']?.toString(),
      culturalSignificance: json['culturalSignificance']?.toString(),
      traditionalFeatures: json['traditionalFeatures']?.toString(),
      culturalExperiences: _parseStringList(json['culturalExperiences']),
      numberOfRooms: json['numberOfRooms'] as int? ?? 0,
      maxGuests: json['maxGuests'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      amenities: _parseStringList(json['amenities']),
      nearCulturalSite: json['nearCulturalSite'] != null
          ? NearCulturalSite.fromJson(json['nearCulturalSite'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Handles String[], comma-separated string, or null safely
  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'category': category,
      'pricePerNight': pricePerNight,
      'imageUrls': imageUrls,
      'isVisible': isVisible,
      'buildingHistory': buildingHistory,
      'culturalSignificance': culturalSignificance,
      'traditionalFeatures': traditionalFeatures,
      'culturalExperiences': culturalExperiences,
      'numberOfRooms': numberOfRooms,
      'maxGuests': maxGuests,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'nearCulturalSite': nearCulturalSite?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class NearCulturalSite {
  final int id;
  final String name;

  NearCulturalSite({required this.id, required this.name});

  factory NearCulturalSite.fromJson(Map<String, dynamic> json) {
    return NearCulturalSite(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}