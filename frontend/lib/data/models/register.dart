class RegisterUser {
  final int? userId;
  final String name;
  final String email;
  final String? phone;
  final String password;
  final String role;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RegisterUser({
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    required this.role,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      userId: json['UserId'] != null ? json['UserId'] as int : null,
      name: json['name'] ?? 'Empty',
      email: json['email'] ?? '',
      phone: json['Phone'] as String?,
      password: json['Password'] ?? '',
      role: json['role'] ?? 'tourist',
      profileImage: json['ProfileImage'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt']!= null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Name': name,
      'Email': email,
      'Phone': phone,
      'Password': password,
      'Role': role,
      'ProfileImage': profileImage,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }
}