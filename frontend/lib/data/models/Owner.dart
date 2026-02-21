class Owner {
  final int userId;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final DateTime? createdAt;

  Owner({
    required this.userId,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.createdAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      userId: json['userId'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unknown Host',
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Helper to get initials (e.g., "Ram Karki" -> "RK")
  String get initials {
    if (name.isEmpty) return "H";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      final first = parts[0];
      final second = parts[1];
      if (first.isNotEmpty && second.isNotEmpty) {
        return '${first[0]}${second[0]}'.toUpperCase();
      }
    }
    return name[0].toUpperCase();
  }
}