// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserProfile {
  /// Unique user identifier
  int get id => throw _privateConstructorUsedError;

  /// User's email address
  String get email => throw _privateConstructorUsedError;

  /// User's phone number
  String get phone => throw _privateConstructorUsedError;

  /// User's first name
  String get firstName => throw _privateConstructorUsedError;

  /// User's last name (optional)
  String? get lastName => throw _privateConstructorUsedError;

  /// Date of birth
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;

  /// Gender
  String? get gender => throw _privateConstructorUsedError;

  /// Profile picture URL
  String? get profilePicture => throw _privateConstructorUsedError;

  /// Profile picture path
  String? get profilePicturePath => throw _privateConstructorUsedError;

  /// Whether user account is active
  bool get isActive => throw _privateConstructorUsedError;

  /// Whether user is verified
  bool get isVerified => throw _privateConstructorUsedError;

  /// Blood group
  String? get bloodGroup => throw _privateConstructorUsedError;

  /// Parent's name
  String? get parentName => throw _privateConstructorUsedError;

  /// Marital status
  String? get maritalStatus => throw _privateConstructorUsedError;

  /// User role
  String? get role => throw _privateConstructorUsedError;

  /// Last login timestamp
  DateTime? get lastLogin => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {int id,
      String email,
      String phone,
      String firstName,
      String? lastName,
      DateTime? dateOfBirth,
      String? gender,
      String? profilePicture,
      String? profilePicturePath,
      bool isActive,
      bool isVerified,
      String? bloodGroup,
      String? parentName,
      String? maritalStatus,
      String? role,
      DateTime? lastLogin});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = null,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? profilePicture = freezed,
    Object? profilePicturePath = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? bloodGroup = freezed,
    Object? parentName = freezed,
    Object? maritalStatus = freezed,
    Object? role = freezed,
    Object? lastLogin = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicturePath: freezed == profilePicturePath
          ? _value.profilePicturePath
          : profilePicturePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      bloodGroup: freezed == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      parentName: freezed == parentName
          ? _value.parentName
          : parentName // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String email,
      String phone,
      String firstName,
      String? lastName,
      DateTime? dateOfBirth,
      String? gender,
      String? profilePicture,
      String? profilePicturePath,
      bool isActive,
      bool isVerified,
      String? bloodGroup,
      String? parentName,
      String? maritalStatus,
      String? role,
      DateTime? lastLogin});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = null,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? profilePicture = freezed,
    Object? profilePicturePath = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? bloodGroup = freezed,
    Object? parentName = freezed,
    Object? maritalStatus = freezed,
    Object? role = freezed,
    Object? lastLogin = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicturePath: freezed == profilePicturePath
          ? _value.profilePicturePath
          : profilePicturePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      bloodGroup: freezed == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      parentName: freezed == parentName
          ? _value.parentName
          : parentName // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$UserProfileImpl extends _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.email,
      required this.phone,
      required this.firstName,
      this.lastName,
      this.dateOfBirth,
      this.gender,
      this.profilePicture,
      this.profilePicturePath,
      required this.isActive,
      required this.isVerified,
      this.bloodGroup,
      this.parentName,
      this.maritalStatus,
      this.role,
      this.lastLogin})
      : super._();

  /// Unique user identifier
  @override
  final int id;

  /// User's email address
  @override
  final String email;

  /// User's phone number
  @override
  final String phone;

  /// User's first name
  @override
  final String firstName;

  /// User's last name (optional)
  @override
  final String? lastName;

  /// Date of birth
  @override
  final DateTime? dateOfBirth;

  /// Gender
  @override
  final String? gender;

  /// Profile picture URL
  @override
  final String? profilePicture;

  /// Profile picture path
  @override
  final String? profilePicturePath;

  /// Whether user account is active
  @override
  final bool isActive;

  /// Whether user is verified
  @override
  final bool isVerified;

  /// Blood group
  @override
  final String? bloodGroup;

  /// Parent's name
  @override
  final String? parentName;

  /// Marital status
  @override
  final String? maritalStatus;

  /// User role
  @override
  final String? role;

  /// Last login timestamp
  @override
  final DateTime? lastLogin;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, phone: $phone, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, profilePicture: $profilePicture, profilePicturePath: $profilePicturePath, isActive: $isActive, isVerified: $isVerified, bloodGroup: $bloodGroup, parentName: $parentName, maritalStatus: $maritalStatus, role: $role, lastLogin: $lastLogin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.profilePicturePath, profilePicturePath) ||
                other.profilePicturePath == profilePicturePath) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.parentName, parentName) ||
                other.parentName == parentName) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      phone,
      firstName,
      lastName,
      dateOfBirth,
      gender,
      profilePicture,
      profilePicturePath,
      isActive,
      isVerified,
      bloodGroup,
      parentName,
      maritalStatus,
      role,
      lastLogin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);
}

abstract class _UserProfile extends UserProfile {
  const factory _UserProfile(
      {required final int id,
      required final String email,
      required final String phone,
      required final String firstName,
      final String? lastName,
      final DateTime? dateOfBirth,
      final String? gender,
      final String? profilePicture,
      final String? profilePicturePath,
      required final bool isActive,
      required final bool isVerified,
      final String? bloodGroup,
      final String? parentName,
      final String? maritalStatus,
      final String? role,
      final DateTime? lastLogin}) = _$UserProfileImpl;
  const _UserProfile._() : super._();

  @override

  /// Unique user identifier
  int get id;
  @override

  /// User's email address
  String get email;
  @override

  /// User's phone number
  String get phone;
  @override

  /// User's first name
  String get firstName;
  @override

  /// User's last name (optional)
  String? get lastName;
  @override

  /// Date of birth
  DateTime? get dateOfBirth;
  @override

  /// Gender
  String? get gender;
  @override

  /// Profile picture URL
  String? get profilePicture;
  @override

  /// Profile picture path
  String? get profilePicturePath;
  @override

  /// Whether user account is active
  bool get isActive;
  @override

  /// Whether user is verified
  bool get isVerified;
  @override

  /// Blood group
  String? get bloodGroup;
  @override

  /// Parent's name
  String? get parentName;
  @override

  /// Marital status
  String? get maritalStatus;
  @override

  /// User role
  String? get role;
  @override

  /// Last login timestamp
  DateTime? get lastLogin;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
