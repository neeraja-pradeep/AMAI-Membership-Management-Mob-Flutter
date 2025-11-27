// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) {
  return _RegistrationRequest.fromJson(json);
}

/// @nodoc
mixin _$RegistrationRequest {
  String get role => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RegistrationRequestCopyWith<RegistrationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegistrationRequestCopyWith<$Res> {
  factory $RegistrationRequestCopyWith(
          RegistrationRequest value, $Res Function(RegistrationRequest) then) =
      _$RegistrationRequestCopyWithImpl<$Res, RegistrationRequest>;
  @useResult
  $Res call({String role});
}

/// @nodoc
class _$RegistrationRequestCopyWithImpl<$Res, $Val extends RegistrationRequest>
    implements $RegistrationRequestCopyWith<$Res> {
  _$RegistrationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegistrationRequestImplCopyWith<$Res>
    implements $RegistrationRequestCopyWith<$Res> {
  factory _$$RegistrationRequestImplCopyWith(_$RegistrationRequestImpl value,
          $Res Function(_$RegistrationRequestImpl) then) =
      __$$RegistrationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String role});
}

/// @nodoc
class __$$RegistrationRequestImplCopyWithImpl<$Res>
    extends _$RegistrationRequestCopyWithImpl<$Res, _$RegistrationRequestImpl>
    implements _$$RegistrationRequestImplCopyWith<$Res> {
  __$$RegistrationRequestImplCopyWithImpl(_$RegistrationRequestImpl _value,
      $Res Function(_$RegistrationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
  }) {
    return _then(_$RegistrationRequestImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegistrationRequestImpl implements _RegistrationRequest {
  const _$RegistrationRequestImpl({required this.role});

  factory _$RegistrationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegistrationRequestImplFromJson(json);

  @override
  final String role;

  @override
  String toString() {
    return 'RegistrationRequest(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationRequestImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationRequestImplCopyWith<_$RegistrationRequestImpl> get copyWith =>
      __$$RegistrationRequestImplCopyWithImpl<_$RegistrationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegistrationRequestImplToJson(
      this,
    );
  }
}

abstract class _RegistrationRequest implements RegistrationRequest {
  const factory _RegistrationRequest({required final String role}) =
      _$RegistrationRequestImpl;

  factory _RegistrationRequest.fromJson(Map<String, dynamic> json) =
      _$RegistrationRequestImpl.fromJson;

  @override
  String get role;
  @override
  @JsonKey(ignore: true)
  _$$RegistrationRequestImplCopyWith<_$RegistrationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
