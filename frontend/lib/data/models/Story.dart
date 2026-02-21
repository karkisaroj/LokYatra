class Story {
  final int id;
  final int culturalSiteId;
  final String title;
  final String storyType;
  final int estimatedReadTimeMinutes;
  final String fullContent;
  final String? historicalContext;
  final String? culturalSignificance;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Story({
    required this.id,
    required this.culturalSiteId,
    required this.title,
    required this.storyType,
    required this.estimatedReadTimeMinutes,
    required this.fullContent,
    this.historicalContext,
    this.culturalSignificance,
    this.imageUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int? ?? 0,
      culturalSiteId: json['culturalSiteId'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      storyType: json['storyType']?.toString() ?? '',
      estimatedReadTimeMinutes: json['estimatedReadTimeMinutes'] as int? ?? 0,
      fullContent: json['fullContent']?.toString() ?? '',
      historicalContext: json['historicalContext']?.toString(),
      culturalSignificance: json['culturalSignificance']?.toString(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
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
      'culturalSiteId': culturalSiteId,
      'title': title,
      'storyType': storyType,
      'estimatedReadTimeMinutes': estimatedReadTimeMinutes,
      'fullContent': fullContent,
      'historicalContext': historicalContext,
      'culturalSignificance': culturalSignificance,
      'imageUrls': imageUrls,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}