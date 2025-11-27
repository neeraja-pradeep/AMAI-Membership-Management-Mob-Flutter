// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) {
  return _ErrorResponse.fromJson(json);
}

/// @nodoc
mixin _$ErrorResponse {
  @JsonKey(name: 'error_code')
  String get errorCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'field_errors')
  Map<String, List<String>>? get fieldErrors =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'retry_after')
  int? get retryAfter => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ErrorResponseCopyWith<ErrorResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ErrorResponseCopyWith<$Res> {
  factory $ErrorResponseCopyWith(
          ErrorResponse value, $Res Function(ErrorResponse) then) =
      _$ErrorResponseCopyWithImpl<$Res, ErrorResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'error_code') String errorCode,
      @JsonKey(name: 'error_message') String errorMessage,
      @JsonKey(name: 'field_errors') Map<String, List<String>>? fieldErrors,
      @JsonKey(name: 'retry_after') int? retryAfter});
}

/// @nodoc
class _$ErrorResponseCopyWithImpl<$Res, $Val extends ErrorResponse>
    implements $ErrorResponseCopyWith<$Res> {
  _$ErrorResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorCode = null,
    Object? errorMessage = null,
    Object? fieldErrors = freezed,
    Object? retryAfter = freezed,
  }) {
    return _then(_value.copyWith(
      errorCode: null == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      fieldErrors: freezed == fieldErrors
          ? _value.fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
      retryAfter: freezed == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ErrorResponseImplCopyWith<$Res>
    implements $ErrorResponseCopyWith<$Res> {
  factory _$$ErrorResponseImplCopyWith(
          _$ErrorResponseImpl value, $Res Function(_$ErrorResponseImpl) then) =
      __$$ErrorResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'error_code') String errorCode,
      @JsonKey(name: 'error_message') String errorMessage,
      @JsonKey(name: 'field_errors') Map<String, List<String>>? fieldErrors,
      @JsonKey(name: 'retry_after') int? retryAfter});
}

/// @nodoc
class __$$ErrorResponseImplCopyWithImpl<$Res>
    extends _$ErrorResponseCopyWithImpl<$Res, _$ErrorResponseImpl>
    implements _$$ErrorResponseImplCopyWith<$Res> {
  __$$ErrorResponseImplCopyWithImpl(
      _$ErrorResponseImpl _value, $Res Function(_$ErrorResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorCode = null,
    Object? errorMessage = null,
    Object? fieldErrors = freezed,
    Object? retryAfter = freezed,
  }) {
    return _then(_$ErrorResponseImpl(
      errorCode: null == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
      retryAfter: freezed == retryAfter
          ? _value.retryAfter
          : retryAfter // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ErrorResponseImpl extends _ErrorResponse {
  const _$ErrorResponseImpl(
      {@JsonKey(name: 'error_code') required this.errorCode,
      @JsonKey(name: 'error_message') required this.errorMessage,
      @JsonKey(name: 'field_errors')
      final Map<String, List<String>>? fieldErrors,
      @JsonKey(name: 'retry_after') this.retryAfter})
      : _fieldErrors = fieldErrors,
        super._();

  factory _$ErrorResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ErrorResponseImplFromJson(json);

  @override
  @JsonKey(name: 'error_code')
  final String errorCode;
  @override
  @JsonKey(name: 'error_message')
  final String errorMessage;
  final Map<String, List<String>>? _fieldErrors;
  @override
  @JsonKey(name: 'field_errors')
  Map<String, List<String>>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'retry_after')
  final int? retryAfter;

  @override
  String toString() {
    return 'ErrorResponse(errorCode: $errorCode, errorMessage: $errorMessage, fieldErrors: $fieldErrors, retryAfter: $retryAfter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorResponseImpl &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors) &&
            (identical(other.retryAfter, retryAfter) ||
                other.retryAfter == retryAfter));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, errorCode, errorMessage,
      const DeepCollectionEquality().hash(_fieldErrors), retryAfter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorResponseImplCopyWith<_$ErrorResponseImpl> get copyWith =>
      __$$ErrorResponseImplCopyWithImpl<_$ErrorResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ErrorResponseImplToJson(
      this,
    );
  }
}

abstract class _ErrorResponse extends ErrorResponse {
  const factory _ErrorResponse(
          {@JsonKey(name: 'error_code') required final String errorCode,
          @JsonKey(name: 'error_message') required final String errorMessage,
          @JsonKey(name: 'field_errors')
          final Map<String, List<String>>? fieldErrors,
          @JsonKey(name: 'retry_after') final int? retryAfter}) =
      _$ErrorResponseImpl;
  const _ErrorResponse._() : super._();

  factory _ErrorResponse.fromJson(Map<String, dynamic> json) =
      _$ErrorResponseImpl.fromJson;

  @override
  @JsonKey(name: 'error_code')
  String get errorCode;
  @override
  @JsonKey(name: 'error_message')
  String get errorMessage;
  @override
  @JsonKey(name: 'field_errors')
  Map<String, List<String>>? get fieldErrors;
  @override
  @JsonKey(name: 'retry_after')
  int? get retryAfter;
  @override
  @JsonKey(ignore: true)
  _$$ErrorResponseImplCopyWith<_$ErrorResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
