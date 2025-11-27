/// Session domain entity
///
/// Represents an authenticated session with tokens and expiry information
class Session {
  final String sessionId;
  final String xcsrfToken;
  final DateTime expiresAt;
  final String? ifModifiedSince;

  const Session({
    required this.sessionId,
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
          sessionId == other.sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() {
    return 'Session(sessionId: $sessionId, expiresAt: $expiresAt, valid: $isValid)';
  }
}
