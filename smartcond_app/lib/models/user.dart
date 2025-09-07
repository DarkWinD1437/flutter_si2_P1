class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String phone;
  final String address;
  final String? profilePicture;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.address,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'resident',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
  bool get isSecurity => role == 'security';
}