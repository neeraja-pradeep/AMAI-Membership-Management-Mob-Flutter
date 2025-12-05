import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'announcement.freezed.dart';

/// Domain entity representing an Announcement
/// Used to display announcement information on the homescreen
@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    /// Unique identifier
    required String id,

    /// Announcement title
    required String title,

    /// Announcement content
    required String content,

    /// Announcement type (general, urgent, etc.)
    required String announcementType,

    /// Priority level (higher = more important)
    required int priority,

    /// Featured image URL
    String? featuredImage,

    /// Publish date
    DateTime? publishDate,

    /// Expiry date
    DateTime? expiryDate,

    /// Whether announcement is published
    required bool isPublished,

    /// View count
    required int viewCount,

    /// Created at timestamp
    required DateTime createdAt,

    /// Author ID
    int? authorId,
  }) = _Announcement;

  const Announcement._();

  /// Check if announcement has expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Check if announcement is urgent (priority >= 3)
  bool get isUrgent => priority >= 3;

  /// Check if announcement is new (created within last 7 days)
  bool get isNew {
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreated <= 7;
  }

  /// Formatted created date for display (e.g., "30 Nov 2025")
  String get displayDate => DateFormat('dd MMM yyyy').format(createdAt);

  /// Formatted relative time (e.g., "2 hours ago", "3 days ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return displayDate;
    }
  }

  /// Truncated content for preview (max 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Display announcement type in readable format
  String get displayType {
    switch (announcementType.toLowerCase()) {
      case 'general':
        return 'General';
      case 'urgent':
        return 'Urgent';
      case 'update':
        return 'Update';
      case 'event':
        return 'Event';
      case 'news':
        return 'News';
      default:
        return announcementType;
    }
  }
}
