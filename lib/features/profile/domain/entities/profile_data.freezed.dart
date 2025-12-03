// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileData {
  UserProfile get userProfile => throw _privateConstructorUsedError;
  MembershipType get membershipType => throw _privateConstructorUsedError;
  String? get membershipNumber => throw _privateConstructorUsedError;
  String? get membershipStatus => throw _privateConstructorUsedError;
  DateTime? get validUntil => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileDataCopyWith<ProfileData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileDataCopyWith<$Res> {
  factory $ProfileDataCopyWith(
          ProfileData value, $Res Function(ProfileData) then) =
      _$ProfileDataCopyWithImpl<$Res, ProfileData>;
  @useResult
  $Res call({
    UserProfile userProfile,
    MembershipType membershipType,
    String? membershipNumber,
    String? membershipStatus,
    DateTime? validUntil,
  });

  $UserProfileCopyWith<$Res> get userProfile;
}

/// @nodoc
class _$ProfileDataCopyWithImpl<$Res, $Val extends ProfileData>
    implements $ProfileDataCopyWith<$Res> {
  _$ProfileDataCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfile = null,
    Object? membershipType = null,
    Object? membershipNumber = freezed,
    Object? membershipStatus = freezed,
    Object? validUntil = freezed,
  }) {
    return _then(_value.copyWith(
      userProfile: null == userProfile
          ? _value.userProfile
          : userProfile as UserProfile,
      membershipType: null == membershipType
          ? _value.membershipType
          : membershipType as MembershipType,
      membershipNumber: freezed == membershipNumber
          ? _value.membershipNumber
          : membershipNumber as String?,
      membershipStatus: freezed == membershipStatus
          ? _value.membershipStatus
          : membershipStatus as String?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res> get userProfile {
    return $UserProfileCopyWith<$Res>(_value.userProfile, (value) {
      return _then(_value.copyWith(userProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileDataImplCopyWith<$Res>
    implements $ProfileDataCopyWith<$Res> {
  factory _$$ProfileDataImplCopyWith(
          _$ProfileDataImpl value, $Res Function(_$ProfileDataImpl) then) =
      __$$ProfileDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserProfile userProfile,
    MembershipType membershipType,
    String? membershipNumber,
    String? membershipStatus,
    DateTime? validUntil,
  });

  @override
  $UserProfileCopyWith<$Res> get userProfile;
}

/// @nodoc
class __$$ProfileDataImplCopyWithImpl<$Res>
    extends _$ProfileDataCopyWithImpl<$Res, _$ProfileDataImpl>
    implements _$$ProfileDataImplCopyWith<$Res> {
  __$$ProfileDataImplCopyWithImpl(
      _$ProfileDataImpl _value, $Res Function(_$ProfileDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfile = null,
    Object? membershipType = null,
    Object? membershipNumber = freezed,
    Object? membershipStatus = freezed,
    Object? validUntil = freezed,
  }) {
    return _then(_$ProfileDataImpl(
      userProfile: null == userProfile
          ? _value.userProfile
          : userProfile as UserProfile,
      membershipType: null == membershipType
          ? _value.membershipType
          : membershipType as MembershipType,
      membershipNumber: freezed == membershipNumber
          ? _value.membershipNumber
          : membershipNumber as String?,
      membershipStatus: freezed == membershipStatus
          ? _value.membershipStatus
          : membershipStatus as String?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil as DateTime?,
    ));
  }
}

/// @nodoc

class _$ProfileDataImpl extends _ProfileData {
  const _$ProfileDataImpl({
    required this.userProfile,
    required this.membershipType,
    this.membershipNumber,
    this.membershipStatus,
    this.validUntil,
  }) : super._();

  @override
  final UserProfile userProfile;
  @override
  final MembershipType membershipType;
  @override
  final String? membershipNumber;
  @override
  final String? membershipStatus;
  @override
  final DateTime? validUntil;

  @override
  String toString() {
    return 'ProfileData(userProfile: $userProfile, membershipType: $membershipType, membershipNumber: $membershipNumber, membershipStatus: $membershipStatus, validUntil: $validUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileDataImpl &&
            (identical(other.userProfile, userProfile) || other.userProfile == userProfile) &&
            (identical(other.membershipType, membershipType) || other.membershipType == membershipType) &&
            (identical(other.membershipNumber, membershipNumber) || other.membershipNumber == membershipNumber) &&
            (identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus) &&
            (identical(other.validUntil, validUntil) || other.validUntil == validUntil));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, userProfile, membershipType, membershipNumber, membershipStatus, validUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileDataImplCopyWith<_$ProfileDataImpl> get copyWith =>
      __$$ProfileDataImplCopyWithImpl<_$ProfileDataImpl>(this, _$identity);
}

abstract class _ProfileData extends ProfileData {
  const factory _ProfileData({
    required final UserProfile userProfile,
    required final MembershipType membershipType,
    final String? membershipNumber,
    final String? membershipStatus,
    final DateTime? validUntil,
  }) = _$ProfileDataImpl;
  const _ProfileData._() : super._();

  @override
  UserProfile get userProfile;
  @override
  MembershipType get membershipType;
  @override
  String? get membershipNumber;
  @override
  String? get membershipStatus;
  @override
  DateTime? get validUntil;
  @override
  @JsonKey(ignore: true)
  _$$ProfileDataImplCopyWith<_$ProfileDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
