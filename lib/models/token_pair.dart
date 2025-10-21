import 'package:fresh_dio/fresh_dio.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
// ИСПРАВЛЕНИЕ: Класс ДОЛЖЕН наследовать от OAuth2Token
class TokenPair extends OAuth2Token {
  TokenPair({
    @JsonKey(name: 'access', required: true) required String accessToken,
    @JsonKey(name: 'refresh') String? refreshToken,
    required String access,
    required String refresh,
  }) : super(
         // Передаем значения в конструктор родителя
         accessToken: accessToken,
         refreshToken: refreshToken,
       );
  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access'],
      access: json['access'],
      refresh: json['refresh'],
      refreshToken: json['refresh'],
    );
  }

  get access => null;

  get refresh => null;

  // Map<String, dynamic> toJson() => _$TokenPairToJson(this);

  // Для полноценной работы с Fresh рекомендуется переопределить copyWith
  @override
  TokenPair copyWith({String? accessToken, String? refreshToken}) {
    return TokenPair(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      access: '',
      refresh: '',
    );
  }
}
