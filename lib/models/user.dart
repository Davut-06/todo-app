class User {
  final int id;
  final String username;
  final String firstName;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      token: json['token'] ?? '', // Токен для дальнейших запросов
    );
  }
}
