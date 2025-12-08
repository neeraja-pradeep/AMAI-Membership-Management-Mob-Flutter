// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembershipStatus {
  /// Unique identifier for the membership
  String get id => throw _privateConstructorUsedError;

  /// Whether the membership is currently active
  bool get isActive => throw _privateConstructorUsedError;

  /// Membership type (student, house_surgeon, practitioner, honorary)
  String get membershipType => throw _privateConstructorUsedError;

  /// Membership validity end date
  DateTime get validUntil => throw _privateConstructorUsedError;

  /// Member's name for display
  String get memberName => throw _privateConstructorUsedError;

  /// Membership number for display
  String get membershipNumber => throw _privateConstructorUsedError;

  /// Membership start date
  DateTime? get startDate => throw _privateConstructorUsedError;

  /// URL to download membership PDF
  String? get membershipPdfUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MembershipStatusCopyWith<MembershipStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipStatusCopyWith<$Res> {
  factory $MembershipStatusCopyWith(
          MembershipStatus value, $Res Function(MembershipStatus) then) =
      _$MembershipStatusCopyWithImpl<$Res, MembershipStatus>;
  @useResult
  $Res call(
      {String id,
      bool isActive,
      String membershipType,
      DateTime validUntil,
      String memberName,
      String membershipNumber,
      DateTime? startDate,
      String? membershipPdfUrl});
}

/// @nodoc
class _$MembershipStatusCopyWithImpl<$Res, $Val extends MembershipStatus>
    implements $MembershipStatusCopyWith<$Res> {
  _$MembershipStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isActive = null,
    Object? membershipType = null,
    Object? validUntil = null,
    Object? memberName = null,
    Object? membershipNumber = null,
    Object? startDate = freezed,
    Object? membershipPdfUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      membershipType: null == membershipType
          ? _value.membershipType
          : membershipType // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
      membershipNumber: null == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      membershipPdfUrl: freezed == membershipPdfUrl
          ? _value.membershipPdfUrl
          : membershipPdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipStatusImplCopyWith<$Res>
    implements $MembershipStatusCopyWith<$Res> {
  factory _$$MembershipStatusImplCopyWith(_$MembershipStatusImpl value,
          $Res Function(_$MembershipStatusImpl) then) =
      __$$MembershipStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      bool isActive,
      String membershipType,
      DateTime validUntil,
      String memberName,
      String membershipNumber,
      DateTime? startDate,
      String? membershipPdfUrl});
}

/// @nodoc
class __$$MembershipStatusImplCopyWithImpl<$Res>
    extends _$MembershipStatusCopyWithImpl<$Res, _$MembershipStatusImpl>
    implements _$$MembershipStatusImplCopyWith<$Res> {
  __$$MembershipStatusImplCopyWithImpl(_$MembershipStatusImpl _value,
      $Res Function(_$MembershipStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isActive = null,
    Object? membershipType = null,
    Object? validUntil = null,
    Object? memberName = null,
    Object? membershipNumber = null,
    Object? startDate = freezed,
    Object? membershipPdfUrl = freezed,
  }) {
    return _then(_$MembershipStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      membershipType: null == membershipType
          ? _value.membershipType
          : membershipType // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
      membershipNumber: null == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      membershipPdfUrl: freezed == membershipPdfUrl
          ? _value.membershipPdfUrl
          : membershipPdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MembershipStatusImpl extends _MembershipStatus {
  const _$MembershipStatusImpl(
      {required this.id,
      required this.isActive,
      required this.membershipType,
      required this.validUntil,
      required this.memberName,
      required this.membershipNumber,
      this.startDate,
      this.membershipPdfUrl})
      : super._();

  /// Unique identifier for the membership
  @override
  final String id;

  /// Whether the membership is currently active
  @override
  final bool isActive;

  /// Membership type (student, house_surgeon, practitioner, honorary)
  @override
  final String membershipType;

  /// Membership validity end date
  @override
  final DateTime validUntil;

  /// Member's name for display
  @override
  final String memberName;

  /// Membership number for display
  @override
  final String membershipNumber;

  /// Membership start date
  @override
  final DateTime? startDate;

  /// URL to download membership PDF
  @override
  final String? membershipPdfUrl;

  @override
  String toString() {
    return 'MembershipStatus(id: $id, isActive: $isActive, membershipType: $membershipType, validUntil: $validUntil, memberName: $memberName, membershipNumber: $membershipNumber, startDate: $startDate, membershipPdfUrl: $membershipPdfUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.membershipType, membershipType) ||
                other.membershipType == membershipType) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName) &&
            (identical(other.membershipNumber, membershipNumber) ||
                other.membershipNumber == membershipNumber) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.membershipPdfUrl, membershipPdfUrl) ||
                other.membershipPdfUrl == membershipPdfUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, isActive, membershipType,
      validUntil, memberName, membershipNumber, startDate, membershipPdfUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipStatusImplCopyWith<_$MembershipStatusImpl> get copyWith =>
      __$$MembershipStatusImplCopyWithImpl<_$MembershipStatusImpl>(
          this, _$identity);
}

abstract class _MembershipStatus extends MembershipStatus {
  const factory _MembershipStatus(
      {required final String id,
      required final bool isActive,
      required final String membershipType,
      required final DateTime validUntil,
      required final String memberName,
      required final String membershipNumber,
      final DateTime? startDate,
      final String? membershipPdfUrl}) = _$MembershipStatusImpl;
  const _MembershipStatus._() : super._();

  @override

  /// Unique identifier for the membership
  String get id;
  @override

  /// Whether the membership is currently active
  bool get isActive;
  @override

  /// Membership type (student, house_surgeon, practitioner, honorary)
  String get membershipType;
  @override

  /// Membership validity end date
  DateTime get validUntil;
  @override

  /// Member's name for display
  String get memberName;
  @override

  /// Membership number for display
  String get membershipNumber;
  @override

  /// Membership start date
  DateTime? get startDate;
  @override

  /// URL to download membership PDF
  String? get membershipPdfUrl;
  @override
  @JsonKey(ignore: true)
  _$$MembershipStatusImplCopyWith<_$MembershipStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
