class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String avatarUrl;
  final List<String> subjects;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.subjects,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String,
      subjects: List<String>.from(json['subjects'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'subjects': subjects,
    };
  }
}
