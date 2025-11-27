/// Session domain entity
///
/// Represents an authenticated session with tokens and expiry information
///
/// NOTE: session_id is stored in HTTP-only cookies by the server
/// and managed by Dio's cookie manager. It is not part of this entity.
class Session {
  final String xcsrfToken;
  final DateTime expiresAt;
  final String? ifModifiedSince;

  const Session({
    required this.xcsrfToken,
    required this.expiresAt,
    this.ifModifiedSince,
  });

  /// Checks if session is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Checks if session is valid (not expired)
  bool get isValid => !isExpired;

  /// Time remaining until expiry
  Duration get timeUntilExpiry {
    return expiresAt.difference(DateTime.now());
  }

  /// Returns true if session expires in less than 5 minutes
  bool get isExpiringSoon {
    return timeUntilExpiry.inMinutes < 5 && !isExpired;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          xcsrfToken == other.xcsrfToken &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => xcsrfToken.hashCode ^ expiresAt.hashCode;

  @override
  String toString() {
    return 'Session(xcsrfToken: ${xcsrfToken.substring(0, 8)}..., expiresAt: $expiresAt, valid: $isValid)';
  }
}
