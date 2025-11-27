import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session.dart';

part 'session_model.g.dart';

/// Session data transfer object (DTO)
///
/// Maps between API JSON and domain Session entity
///
/// NOTE: session_id is stored in cookies by Dio, not in this model
@JsonSerializable()
class SessionModel {
  @JsonKey(name: 'xcsrf_token')
  final String xcsrfToken;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'if_modified_since')
  final String? ifModifiedSince;

  const SessionModel({
    required this.xcsrfToken,
    required this.expiresAt,
    this.ifModifiedSince,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  /// Convert to domain entity
  Session toEntity() {
    return Session(
      xcsrfToken: xcsrfToken,
      expiresAt: DateTime.parse(expiresAt),
      ifModifiedSince: ifModifiedSince,
    );
  }

  /// Create from domain entity
  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      xcsrfToken: session.xcsrfToken,
      expiresAt: session.expiresAt.toIso8601String(),
      ifModifiedSince: session.ifModifiedSince,
    );
  }

  SessionModel copyWith({
    String? xcsrfToken,
    String? expiresAt,
    String? ifModifiedSince,
  }) {
    return SessionModel(
      xcsrfToken: xcsrfToken ?? this.xcsrfToken,
      expiresAt: expiresAt ?? this.expiresAt,
      ifModifiedSince: ifModifiedSince ?? this.ifModifiedSince,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModel &&
          runtimeType == other.runtimeType &&
          xcsrfToken == other.xcsrfToken &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => xcsrfToken.hashCode ^ expiresAt.hashCode;
}
