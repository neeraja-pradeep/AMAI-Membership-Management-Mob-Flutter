// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nominee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Nominee {
  /// Unique identifier
  int get id => throw _privateConstructorUsedError;

  /// Nominee's full name
  String get nomineeName => throw _privateConstructorUsedError;

  /// Relationship to policy holder
  String get relationship => throw _privateConstructorUsedError;

  /// Contact number
  String get contactNumber => throw _privateConstructorUsedError;

  /// Email address
  String? get email => throw _privateConstructorUsedError;

  /// Address
  String? get address => throw _privateConstructorUsedError;

  /// Date of birth
  String? get dateOfBirth => throw _privateConstructorUsedError;

  /// Allocation percentage
  String? get allocationPercentage => throw _privateConstructorUsedError;

  /// Whether this is the primary nominee
  bool get isPrimary => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NomineeCopyWith<Nominee> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NomineeCopyWith<$Res> {
  factory $NomineeCopyWith(Nominee value, $Res Function(Nominee) then) =
      _$NomineeCopyWithImpl<$Res, Nominee>;
  @useResult
  $Res call(
      {int id,
      String nomineeName,
      String relationship,
      String contactNumber,
      String? email,
      String? address,
      String? dateOfBirth,
      String? allocationPercentage,
      bool isPrimary});
}

/// @nodoc
class _$NomineeCopyWithImpl<$Res, $Val extends Nominee>
    implements $NomineeCopyWith<$Res> {
  _$NomineeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nomineeName = null,
    Object? relationship = null,
    Object? contactNumber = null,
    Object? email = freezed,
    Object? address = freezed,
    Object? dateOfBirth = freezed,
    Object? allocationPercentage = freezed,
    Object? isPrimary = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nomineeName: null == nomineeName
          ? _value.nomineeName
          : nomineeName // ignore: cast_nullable_to_non_nullable
              as String,
      relationship: null == relationship
          ? _value.relationship
          : relationship // ignore: cast_nullable_to_non_nullable
              as String,
      contactNumber: null == contactNumber
          ? _value.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      allocationPercentage: freezed == allocationPercentage
          ? _value.allocationPercentage
          : allocationPercentage // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NomineeImplCopyWith<$Res> implements $NomineeCopyWith<$Res> {
  factory _$$NomineeImplCopyWith(
          _$NomineeImpl value, $Res Function(_$NomineeImpl) then) =
      __$$NomineeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String nomineeName,
      String relationship,
      String contactNumber,
      String? email,
      String? address,
      String? dateOfBirth,
      String? allocationPercentage,
      bool isPrimary});
}

/// @nodoc
class __$$NomineeImplCopyWithImpl<$Res>
    extends _$NomineeCopyWithImpl<$Res, _$NomineeImpl>
    implements _$$NomineeImplCopyWith<$Res> {
  __$$NomineeImplCopyWithImpl(
      _$NomineeImpl _value, $Res Function(_$NomineeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nomineeName = null,
    Object? relationship = null,
    Object? contactNumber = null,
    Object? email = freezed,
    Object? address = freezed,
    Object? dateOfBirth = freezed,
    Object? allocationPercentage = freezed,
    Object? isPrimary = null,
  }) {
    return _then(_$NomineeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nomineeName: null == nomineeName
          ? _value.nomineeName
          : nomineeName // ignore: cast_nullable_to_non_nullable
              as String,
      relationship: null == relationship
          ? _value.relationship
          : relationship // ignore: cast_nullable_to_non_nullable
              as String,
      contactNumber: null == contactNumber
          ? _value.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as String?,
      allocationPercentage: freezed == allocationPercentage
          ? _value.allocationPercentage
          : allocationPercentage // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NomineeImpl extends _Nominee {
  const _$NomineeImpl(
      {required this.id,
      required this.nomineeName,
      required this.relationship,
      required this.contactNumber,
      this.email,
      this.address,
      this.dateOfBirth,
      this.allocationPercentage,
      this.isPrimary = false})
      : super._();

  /// Unique identifier
  @override
  final int id;

  /// Nominee's full name
  @override
  final String nomineeName;

  /// Relationship to policy holder
  @override
  final String relationship;

  /// Contact number
  @override
  final String contactNumber;

  /// Email address
  @override
  final String? email;

  /// Address
  @override
  final String? address;

  /// Date of birth
  @override
  final String? dateOfBirth;

  /// Allocation percentage
  @override
  final String? allocationPercentage;

  /// Whether this is the primary nominee
  @override
  @JsonKey()
  final bool isPrimary;

  @override
  String toString() {
    return 'Nominee(id: $id, nomineeName: $nomineeName, relationship: $relationship, contactNumber: $contactNumber, email: $email, address: $address, dateOfBirth: $dateOfBirth, allocationPercentage: $allocationPercentage, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NomineeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nomineeName, nomineeName) ||
                other.nomineeName == nomineeName) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship) &&
            (identical(other.contactNumber, contactNumber) ||
                other.contactNumber == contactNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.allocationPercentage, allocationPercentage) ||
                other.allocationPercentage == allocationPercentage) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nomineeName,
      relationship,
      contactNumber,
      email,
      address,
      dateOfBirth,
      allocationPercentage,
      isPrimary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NomineeImplCopyWith<_$NomineeImpl> get copyWith =>
      __$$NomineeImplCopyWithImpl<_$NomineeImpl>(this, _$identity);
}

abstract class _Nominee extends Nominee {
  const factory _Nominee(
      {required final int id,
      required final String nomineeName,
      required final String relationship,
      required final String contactNumber,
      final String? email,
      final String? address,
      final String? dateOfBirth,
      final String? allocationPercentage,
      final bool isPrimary}) = _$NomineeImpl;
  const _Nominee._() : super._();

  @override

  /// Unique identifier
  int get id;
  @override

  /// Nominee's full name
  String get nomineeName;
  @override

  /// Relationship to policy holder
  String get relationship;
  @override

  /// Contact number
  String get contactNumber;
  @override

  /// Email address
  String? get email;
  @override

  /// Address
  String? get address;
  @override

  /// Date of birth
  String? get dateOfBirth;
  @override

  /// Allocation percentage
  String? get allocationPercentage;
  @override

  /// Whether this is the primary nominee
  bool get isPrimary;
  @override
  @JsonKey(ignore: true)
  _$$NomineeImplCopyWith<_$NomineeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
