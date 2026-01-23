// lib/core/network/models/refresh_jwt_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'refresh_jwt_response.g.dart';

@JsonSerializable()
class RefreshJwtResponse {
  const RefreshJwtResponse({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;

  factory RefreshJwtResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshJwtResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshJwtResponseToJson(this);
}