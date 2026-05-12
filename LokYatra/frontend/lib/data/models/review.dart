class Review {
  final int id;
  final int touristId;
  final String touristName;
  final String touristImage;
  final int? homestayId;
  final int? bookingId;
  final int? siteId;
  final String? homestayName;
  final String? siteName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.touristId,
    required this.touristName,
    required this.touristImage,
    this.homestayId,
    this.bookingId,
    this.siteId,
    this.homestayName,
    this.siteName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int? ?? 0,
      touristId: json['touristId'] as int? ?? 0,
      touristName: json['touristName']?.toString() ?? '',
      touristImage: json['touristImage']?.toString() ?? '',
      homestayId: json['homestayId'] as int?,
      bookingId: json['bookingId'] as int?,
      siteId: json['siteId'] as int?,
      homestayName: json['homestayName']?.toString(),
      siteName: json['siteName']?.toString(),
      rating: json['rating'] as int? ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}