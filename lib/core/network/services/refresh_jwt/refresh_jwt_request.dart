// lib/core/network/models/refresh_jwt.dart
import 'package:json_annotation/json_annotation.dart';

part 'refresh_jwt_request.g.dart';

@JsonSerializable()
class RefreshJwtRequest {
  const RefreshJwtRequest({required this.refreshToken});

  final String refreshToken;

  factory RefreshJwtRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshJwtRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshJwtRequestToJson(this);
}