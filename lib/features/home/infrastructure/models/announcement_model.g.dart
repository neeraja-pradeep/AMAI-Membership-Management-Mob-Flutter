// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      announcementType: json['announcement_type'] as String,
      priority: (json['priority'] as num).toInt(),
      isPublished: json['is_published'] as bool,
      viewCount: (json['view_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
      featuredImage: json['featured_image'] as String?,
      featuredImageDetails:
          json['featured_image_details'] as Map<String, dynamic>?,
      publishDate: json['publish_date'] as String?,
      expiryDate: json['expiry_date'] as String?,
      updatedAt: json['updated_at'] as String?,
      author: (json['author'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AnnouncementModelToJson(AnnouncementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'announcement_type': instance.announcementType,
      'priority': instance.priority,
      'featured_image': instance.featuredImage,
      'featured_image_details': instance.featuredImageDetails,
      'publish_date': instance.publishDate,
      'expiry_date': instance.expiryDate,
      'is_published': instance.isPublished,
      'view_count': instance.viewCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'author': instance.author,
    };

AnnouncementListResponse _$AnnouncementListResponseFromJson(
        Map<String, dynamic> json) =>
    AnnouncementListResponse(
      count: (json['count'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$AnnouncementListResponseToJson(
        AnnouncementListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'results': instance.results,
      'next': instance.next,
      'previous': instance.previous,
    };
