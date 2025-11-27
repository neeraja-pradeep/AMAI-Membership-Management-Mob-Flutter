import 'dart:async';

/// Request deduplication pool to prevent concurrent duplicate requests
///
/// Problem: Same endpoint called twice simultaneously causes:
/// - Duplicate network calls
/// - Race conditions
/// - Unnecessary bandwidth usage
///
/// Solution: Share a single Future between multiple callers
class RequestPool {
  /// Active in-flight requests mapped by cache key
  final Map<String, Completer<dynamic>> _activeRequests = {};

  /// Deduplicates requests by cache key
  ///
  /// If a request with the same key is already in flight:
  /// - Return the existing Future
  /// - Don't make a new network call
  ///
  /// If no request is active:
  /// - Register new request
  /// - Execute the operation
  /// - Notify all listeners on completion
  /// - Clean up from pool
  Future<T> dedupe<T>(String key, Future<T> Function() request) {
    // Check if request already in flight
    if (_activeRequests.containsKey(key)) {
      return _activeRequests[key]!.future as Future<T>;
    }

    // Create new completer for this request
    final completer = Completer<T>();
    _activeRequests[key] = completer as Completer;

    // Execute the request
    request().then((result) {
      // Complete successfully
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      _activeRequests.remove(key);
    }).catchError((error) {
      // Complete with error
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      _activeRequests.remove(key);
    });

    return completer.future;
  }

  /// Checks if a request is currently in flight
  bool isRequestActive(String key) {
    return _activeRequests.containsKey(key);
  }

  /// Gets the number of active requests
  int get activeRequestCount => _activeRequests.length;

  /// Cancels all active requests
  /// Useful for cleanup on logout or app termination
  void cancelAll() {
    for (final completer in _activeRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Request cancelled'),
        );
      }
    }
    _activeRequests.clear();
  }

  /// Cancels a specific request by key
  void cancel(String key) {
    final completer = _activeRequests[key];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        Exception('Request cancelled'),
      );
      _activeRequests.remove(key);
    }
  }
}
