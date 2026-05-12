class RegisterUser {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? profileImage;

  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "phoneNumber": phoneNumber,
      "profileImage": profileImage,
    };
  }

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'tourist',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
    );
  }
}