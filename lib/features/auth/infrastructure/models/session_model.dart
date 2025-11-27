import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/session.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

/// Session data transfer object (DTO)
///
/// Maps between API JSON and domain Session entity
@freezed
class SessionModel with _$SessionModel {
  const SessionModel._();

  const factory SessionModel({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'xcsrf_token') required String xcsrfToken,
    @JsonKey(name: 'expires_at') required String expiresAt,
    @JsonKey(name: 'if_modified_since') String? ifModifiedSince,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  /// Convert to domain entity
  Session toEntity() {
    return Session(
      sessionId: sessionId,
      xcsrfToken: xcsrfToken,
      expiresAt: DateTime.parse(expiresAt),
      ifModifiedSince: ifModifiedSince,
    );
  }

  /// Create from domain entity
  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      sessionId: session.sessionId,
      xcsrfToken: session.xcsrfToken,
      expiresAt: session.expiresAt.toIso8601String(),
      ifModifiedSince: session.ifModifiedSince,
    );
  }
}
