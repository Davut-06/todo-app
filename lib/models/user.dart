class User {
  final int id;
  final String username;
  final String accessToken;
  final String refreshToken;

  User({
    required this.id,
    required this.username,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int,
      username: json['username'] as String,
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }
}
