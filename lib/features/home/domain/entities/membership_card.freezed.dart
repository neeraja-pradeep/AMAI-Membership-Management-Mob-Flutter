// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// ignore_for_file: implementation_imports
import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:collection/src/unmodifiable_wrappers.dart'
    show EqualUnmodifiableListView;

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembershipCard {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Member's full name (user_first_name from API)
  String get holderName => throw _privateConstructorUsedError;

  /// Membership number for display
  String get membershipNumber => throw _privateConstructorUsedError;

  /// Membership validity end date
  DateTime get validUntil => throw _privateConstructorUsedError;

  /// Whether the membership is currently active
  bool get isActive => throw _privateConstructorUsedError;

  /// User ID from the API (for profile operations)
  int? get userId => throw _privateConstructorUsedError;

  /// Membership type (student, house_surgeon, practitioner, honorary)
  String? get membershipType => throw _privateConstructorUsedError;

  /// Membership start date
  DateTime? get startDate => throw _privateConstructorUsedError;

  /// Academic details (list of qualifications like UG, PG, PhD, etc.)
  List<String>? get academicDetails => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MembershipCardCopyWith<MembershipCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipCardCopyWith<$Res> {
  factory $MembershipCardCopyWith(
          MembershipCard value, $Res Function(MembershipCard) then) =
      _$MembershipCardCopyWithImpl<$Res, MembershipCard>;
  @useResult
  $Res call(
      {String id,
      String holderName,
      String membershipNumber,
      DateTime validUntil,
      bool isActive,
      int? userId,
      String? membershipType,
      DateTime? startDate,
      List<String>? academicDetails});
}

/// @nodoc
class _$MembershipCardCopyWithImpl<$Res, $Val extends MembershipCard>
    implements $MembershipCardCopyWith<$Res> {
  _$MembershipCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holderName = null,
    Object? membershipNumber = null,
    Object? validUntil = null,
    Object? isActive = null,
    Object? userId = freezed,
    Object? membershipType = freezed,
    Object? startDate = freezed,
    Object? academicDetails = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holderName: null == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String,
      membershipNumber: null == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      membershipType: freezed == membershipType
          ? _value.membershipType
          : membershipType // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicDetails: freezed == academicDetails
          ? _value.academicDetails
          : academicDetails // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipCardImplCopyWith<$Res>
    implements $MembershipCardCopyWith<$Res> {
  factory _$$MembershipCardImplCopyWith(_$MembershipCardImpl value,
          $Res Function(_$MembershipCardImpl) then) =
      __$$MembershipCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String holderName,
      String membershipNumber,
      DateTime validUntil,
      bool isActive,
      int? userId,
      String? membershipType,
      DateTime? startDate,
      List<String>? academicDetails});
}

/// @nodoc
class __$$MembershipCardImplCopyWithImpl<$Res>
    extends _$MembershipCardCopyWithImpl<$Res, _$MembershipCardImpl>
    implements _$$MembershipCardImplCopyWith<$Res> {
  __$$MembershipCardImplCopyWithImpl(
      _$MembershipCardImpl _value, $Res Function(_$MembershipCardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holderName = null,
    Object? membershipNumber = null,
    Object? validUntil = null,
    Object? isActive = null,
    Object? userId = freezed,
    Object? membershipType = freezed,
    Object? startDate = freezed,
    Object? academicDetails = freezed,
  }) {
    return _then(_$MembershipCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holderName: null == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String,
      membershipNumber: null == membershipNumber
          ? _value.membershipNumber
          : membershipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      membershipType: freezed == membershipType
          ? _value.membershipType
          : membershipType // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      academicDetails: freezed == academicDetails
          ? _value._academicDetails
          : academicDetails // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$MembershipCardImpl extends _MembershipCard {
  const _$MembershipCardImpl(
      {required this.id,
      required this.holderName,
      required this.membershipNumber,
      required this.validUntil,
      required this.isActive,
      this.userId,
      this.membershipType,
      this.startDate,
      final List<String>? academicDetails})
      : _academicDetails = academicDetails,
        super._();

  /// Unique identifier
  @override
  final String id;

  /// Member's full name (user_first_name from API)
  @override
  final String holderName;

  /// Membership number for display
  @override
  final String membershipNumber;

  /// Membership validity end date
  @override
  final DateTime validUntil;

  /// Whether the membership is currently active
  @override
  final bool isActive;

  /// User ID from the API (for profile operations)
  @override
  final int? userId;

  /// Membership type (student, house_surgeon, practitioner, honorary)
  @override
  final String? membershipType;

  /// Membership start date
  @override
  final DateTime? startDate;

  /// Academic details (list of qualifications like UG, PG, PhD, etc.)
  final List<String>? _academicDetails;

  /// Academic details (list of qualifications like UG, PG, PhD, etc.)
  @override
  List<String>? get academicDetails {
    final value = _academicDetails;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MembershipCard(id: $id, holderName: $holderName, membershipNumber: $membershipNumber, validUntil: $validUntil, isActive: $isActive, userId: $userId, membershipType: $membershipType, startDate: $startDate, academicDetails: $academicDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.holderName, holderName) ||
                other.holderName == holderName) &&
            (identical(other.membershipNumber, membershipNumber) ||
                other.membershipNumber == membershipNumber) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.userId, userId) ||
                other.userId == userId) &&
            (identical(other.membershipType, membershipType) ||
                other.membershipType == membershipType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            const DeepCollectionEquality()
                .equals(other._academicDetails, _academicDetails));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      holderName,
      membershipNumber,
      validUntil,
      isActive,
      userId,
      membershipType,
      startDate,
      const DeepCollectionEquality().hash(_academicDetails));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipCardImplCopyWith<_$MembershipCardImpl> get copyWith =>
      __$$MembershipCardImplCopyWithImpl<_$MembershipCardImpl>(
          this, _$identity);
}

abstract class _MembershipCard extends MembershipCard {
  const factory _MembershipCard(
      {required final String id,
      required final String holderName,
      required final String membershipNumber,
      required final DateTime validUntil,
      required final bool isActive,
      final int? userId,
      final String? membershipType,
      final DateTime? startDate,
      final List<String>? academicDetails}) = _$MembershipCardImpl;
  const _MembershipCard._() : super._();

  @override

  /// Unique identifier
  String get id;
  @override

  /// Member's full name (user_first_name from API)
  String get holderName;
  @override

  /// Membership number for display
  String get membershipNumber;
  @override

  /// Membership validity end date
  DateTime get validUntil;
  @override

  /// Whether the membership is currently active
  bool get isActive;
  @override

  /// User ID from the API (for profile operations)
  int? get userId;
  @override

  /// Membership type (student, house_surgeon, practitioner, honorary)
  String? get membershipType;
  @override

  /// Membership start date
  DateTime? get startDate;
  @override

  /// Academic details (list of qualifications like UG, PG, PhD, etc.)
  List<String>? get academicDetails;
  @override
  @JsonKey(ignore: true)
  _$$MembershipCardImplCopyWith<_$MembershipCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
