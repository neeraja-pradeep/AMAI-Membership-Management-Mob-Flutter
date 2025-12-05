import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/home/domain/entities/announcement.dart';

part 'announcement_model.g.dart';

/// Infrastructure model for Announcement with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.announcementType,
    required this.priority,
    required this.isPublished,
    required this.viewCount,
    required this.createdAt,
    this.featuredImage,
    this.featuredImageDetails,
    this.publishDate,
    this.expiryDate,
    this.updatedAt,
    this.author,
  });

  /// Creates model from JSON map
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'announcement_type')
  final String announcementType;

  @JsonKey(name: 'priority')
  final int priority;

  @JsonKey(name: 'featured_image')
  final String? featuredImage;

  @JsonKey(name: 'featured_image_details')
  final Map<String, dynamic>? featuredImageDetails;

  @JsonKey(name: 'publish_date')
  final String? publishDate;

  @JsonKey(name: 'expiry_date')
  final String? expiryDate;

  @JsonKey(name: 'is_published')
  final bool isPublished;

  @JsonKey(name: 'view_count')
  final int viewCount;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'author')
  final int? author;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  /// Converts to domain entity
  Announcement toDomain() {
    return Announcement(
      id: id.toString(),
      title: title,
      content: content,
      announcementType: announcementType,
      priority: priority,
      featuredImage: featuredImage,
      publishDate: publishDate != null ? _parseDateTime(publishDate!) : null,
      expiryDate: expiryDate != null ? _parseDateTime(expiryDate!) : null,
      isPublished: isPublished,
      viewCount: viewCount,
      createdAt: _parseDateTime(createdAt),
      authorId: author,
    );
  }

  /// Parses ISO8601 datetime string from API
  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Return current date as fallback
      return DateTime.now();
    }
  }
}

/// Response wrapper for paginated announcements list
@JsonSerializable()
class AnnouncementListResponse {
  const AnnouncementListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementListResponseFromJson(json);

  @JsonKey(name: 'count')
  final int count;

  @JsonKey(name: 'results')
  final List<AnnouncementModel> results;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  Map<String, dynamic> toJson() => _$AnnouncementListResponseToJson(this);

  /// Gets the active announcements (published and not expired, sorted by priority)
  List<AnnouncementModel> get activeAnnouncements {
    final now = DateTime.now();
    return results
        .where((announcement) {
          if (!announcement.isPublished) return false;
          if (announcement.expiryDate != null) {
            final expiry = AnnouncementModel._parseDateTime(announcement.expiryDate!);
            if (expiry.isBefore(now)) return false;
          }
          return true;
        })
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority)); // Higher priority first
  }
}
