// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Announcement {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Announcement title
  String get title => throw _privateConstructorUsedError;

  /// Announcement content
  String get content => throw _privateConstructorUsedError;

  /// Announcement type (general, urgent, etc.)
  String get announcementType => throw _privateConstructorUsedError;

  /// Priority level (higher = more important)
  int get priority => throw _privateConstructorUsedError;

  /// Featured image URL
  String? get featuredImage => throw _privateConstructorUsedError;

  /// Publish date
  DateTime? get publishDate => throw _privateConstructorUsedError;

  /// Expiry date
  DateTime? get expiryDate => throw _privateConstructorUsedError;

  /// Whether announcement is published
  bool get isPublished => throw _privateConstructorUsedError;

  /// View count
  int get viewCount => throw _privateConstructorUsedError;

  /// Created at timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Author ID
  int? get authorId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AnnouncementCopyWith<Announcement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementCopyWith<$Res> {
  factory $AnnouncementCopyWith(
          Announcement value, $Res Function(Announcement) then) =
      _$AnnouncementCopyWithImpl<$Res, Announcement>;
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      String announcementType,
      int priority,
      String? featuredImage,
      DateTime? publishDate,
      DateTime? expiryDate,
      bool isPublished,
      int viewCount,
      DateTime createdAt,
      int? authorId});
}

/// @nodoc
class _$AnnouncementCopyWithImpl<$Res, $Val extends Announcement>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? announcementType = null,
    Object? priority = null,
    Object? featuredImage = freezed,
    Object? publishDate = freezed,
    Object? expiryDate = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? authorId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      announcementType: null == announcementType
          ? _value.announcementType
          : announcementType // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      featuredImage: freezed == featuredImage
          ? _value.featuredImage
          : featuredImage // ignore: cast_nullable_to_non_nullable
              as String?,
      publishDate: freezed == publishDate
          ? _value.publishDate
          : publishDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnnouncementImplCopyWith<$Res>
    implements $AnnouncementCopyWith<$Res> {
  factory _$$AnnouncementImplCopyWith(
          _$AnnouncementImpl value, $Res Function(_$AnnouncementImpl) then) =
      __$$AnnouncementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      String announcementType,
      int priority,
      String? featuredImage,
      DateTime? publishDate,
      DateTime? expiryDate,
      bool isPublished,
      int viewCount,
      DateTime createdAt,
      int? authorId});
}

/// @nodoc
class __$$AnnouncementImplCopyWithImpl<$Res>
    extends _$AnnouncementCopyWithImpl<$Res, _$AnnouncementImpl>
    implements _$$AnnouncementImplCopyWith<$Res> {
  __$$AnnouncementImplCopyWithImpl(
      _$AnnouncementImpl _value, $Res Function(_$AnnouncementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? announcementType = null,
    Object? priority = null,
    Object? featuredImage = freezed,
    Object? publishDate = freezed,
    Object? expiryDate = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? authorId = freezed,
  }) {
    return _then(_$AnnouncementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      announcementType: null == announcementType
          ? _value.announcementType
          : announcementType // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      featuredImage: freezed == featuredImage
          ? _value.featuredImage
          : featuredImage // ignore: cast_nullable_to_non_nullable
              as String?,
      publishDate: freezed == publishDate
          ? _value.publishDate
          : publishDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$AnnouncementImpl extends _Announcement {
  const _$AnnouncementImpl(
      {required this.id,
      required this.title,
      required this.content,
      required this.announcementType,
      required this.priority,
      this.featuredImage,
      this.publishDate,
      this.expiryDate,
      required this.isPublished,
      required this.viewCount,
      required this.createdAt,
      this.authorId})
      : super._();

  /// Unique identifier
  @override
  final String id;

  /// Announcement title
  @override
  final String title;

  /// Announcement content
  @override
  final String content;

  /// Announcement type (general, urgent, etc.)
  @override
  final String announcementType;

  /// Priority level (higher = more important)
  @override
  final int priority;

  /// Featured image URL
  @override
  final String? featuredImage;

  /// Publish date
  @override
  final DateTime? publishDate;

  /// Expiry date
  @override
  final DateTime? expiryDate;

  /// Whether announcement is published
  @override
  final bool isPublished;

  /// View count
  @override
  final int viewCount;

  /// Created at timestamp
  @override
  final DateTime createdAt;

  /// Author ID
  @override
  final int? authorId;

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, content: $content, announcementType: $announcementType, priority: $priority, featuredImage: $featuredImage, publishDate: $publishDate, expiryDate: $expiryDate, isPublished: $isPublished, viewCount: $viewCount, createdAt: $createdAt, authorId: $authorId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.announcementType, announcementType) ||
                other.announcementType == announcementType) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.featuredImage, featuredImage) ||
                other.featuredImage == featuredImage) &&
            (identical(other.publishDate, publishDate) ||
                other.publishDate == publishDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      content,
      announcementType,
      priority,
      featuredImage,
      publishDate,
      expiryDate,
      isPublished,
      viewCount,
      createdAt,
      authorId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      __$$AnnouncementImplCopyWithImpl<_$AnnouncementImpl>(this, _$identity);
}

abstract class _Announcement extends Announcement {
  const factory _Announcement(
      {required final String id,
      required final String title,
      required final String content,
      required final String announcementType,
      required final int priority,
      final String? featuredImage,
      final DateTime? publishDate,
      final DateTime? expiryDate,
      required final bool isPublished,
      required final int viewCount,
      required final DateTime createdAt,
      final int? authorId}) = _$AnnouncementImpl;
  const _Announcement._() : super._();

  @override

  /// Unique identifier
  String get id;
  @override

  /// Announcement title
  String get title;
  @override

  /// Announcement content
  String get content;
  @override

  /// Announcement type (general, urgent, etc.)
  String get announcementType;
  @override

  /// Priority level (higher = more important)
  int get priority;
  @override

  /// Featured image URL
  String? get featuredImage;
  @override

  /// Publish date
  DateTime? get publishDate;
  @override

  /// Expiry date
  DateTime? get expiryDate;
  @override

  /// Whether announcement is published
  bool get isPublished;
  @override

  /// View count
  int get viewCount;
  @override

  /// Created at timestamp
  DateTime get createdAt;
  @override

  /// Author ID
  int? get authorId;
  @override
  @JsonKey(ignore: true)
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
