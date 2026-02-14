class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool ?isActive;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isActive,
    required this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? false,
      phone: json['phoneNumber'],
      role: json['role'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": id,
      "name": name,
      "email": email,
      "IsActive":isActive,
      "phoneNumber": phone,
      "role": role,
      "profileImage": profileImage,
    };
  }

  List<Object?> get props => [id, name, email, phone, role, profileImage,isActive];
}