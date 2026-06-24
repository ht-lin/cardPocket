import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

/// Account-level policy for what happens to cards once they expire.
enum ExpiryPolicy {
  /// Default: expired cards are only marked, never auto-deleted.
  @JsonValue('KEEP')
  keep,

  /// Expired cards are automatically moved to trash by a backend cron job.
  @JsonValue('AUTO_TRASH')
  autoTrash,
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String userName,
    required bool emailVerified,
    // Defaulted so an older backend that omits the field doesn't break parsing.
    @Default(ExpiryPolicy.keep) ExpiryPolicy expiryPolicy,
    // Whether this account can be found via friend search (PATCH /api/users/me).
    @Default(true) bool discoverable,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String userName,
    required bool gdprConsent,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
