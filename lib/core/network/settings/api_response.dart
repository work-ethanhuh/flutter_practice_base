import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse {
  @JsonKey(includeIfNull: false)
  dynamic result;
  @JsonKey(includeIfNull: false)
  int? code;
  @JsonKey(includeIfNull: false)
  String? message;

  ApiResponse({
    this.result,
    this.code,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
