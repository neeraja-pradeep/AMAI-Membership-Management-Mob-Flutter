// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembershipState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipStateCopyWith<$Res> {
  factory $MembershipStateCopyWith(
          MembershipState value, $Res Function(MembershipState) then) =
      _$MembershipStateCopyWithImpl<$Res, MembershipState>;
}

/// @nodoc
class _$MembershipStateCopyWithImpl<$Res, $Val extends MembershipState>
    implements $MembershipStateCopyWith<$Res> {
  _$MembershipStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl extends _Initial {
  const _$InitialImpl() : super._();

  @override
  String toString() {
    return 'MembershipState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial extends MembershipState {
  const factory _Initial() = _$InitialImpl;
  const _Initial._() : super._();
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MembershipCard? previousData});

  $MembershipCardCopyWith<$Res>? get previousData;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? previousData = freezed,
  }) {
    return _then(_$LoadingImpl(
      previousData: freezed == previousData
          ? _value.previousData
          : previousData // ignore: cast_nullable_to_non_nullable
              as MembershipCard?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $MembershipCardCopyWith<$Res>? get previousData {
    if (_value.previousData == null) {
      return null;
    }

    return $MembershipCardCopyWith<$Res>(_value.previousData!, (value) {
      return _then(_value.copyWith(previousData: value));
    });
  }
}

/// @nodoc

class _$LoadingImpl extends _Loading {
  const _$LoadingImpl({this.previousData}) : super._();

  @override
  final MembershipCard? previousData;

  @override
  String toString() {
    return 'MembershipState.loading(previousData: $previousData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadingImpl &&
            (identical(other.previousData, previousData) ||
                other.previousData == previousData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, previousData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      __$$LoadingImplCopyWithImpl<_$LoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return loading(previousData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return loading?.call(previousData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(previousData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading extends MembershipState {
  const factory _Loading({final MembershipCard? previousData}) = _$LoadingImpl;
  const _Loading._() : super._();

  MembershipCard? get previousData;
  @JsonKey(ignore: true)
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MembershipCard membershipCard});

  $MembershipCardCopyWith<$Res> get membershipCard;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipCard = null,
  }) {
    return _then(_$LoadedImpl(
      membershipCard: null == membershipCard
          ? _value.membershipCard
          : membershipCard // ignore: cast_nullable_to_non_nullable
              as MembershipCard,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $MembershipCardCopyWith<$Res> get membershipCard {
    return $MembershipCardCopyWith<$Res>(_value.membershipCard, (value) {
      return _then(_value.copyWith(membershipCard: value));
    });
  }
}

/// @nodoc

class _$LoadedImpl extends _Loaded {
  const _$LoadedImpl({required this.membershipCard}) : super._();

  @override
  final MembershipCard membershipCard;

  @override
  String toString() {
    return 'MembershipState.loaded(membershipCard: $membershipCard)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.membershipCard, membershipCard) ||
                other.membershipCard == membershipCard));
  }

  @override
  int get hashCode => Object.hash(runtimeType, membershipCard);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return loaded(membershipCard);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return loaded?.call(membershipCard);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(membershipCard);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded extends MembershipState {
  const factory _Loaded({required final MembershipCard membershipCard}) =
      _$LoadedImpl;
  const _Loaded._() : super._();

  MembershipCard get membershipCard;
  @JsonKey(ignore: true)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure, MembershipCard? cachedData});

  $MembershipCardCopyWith<$Res>? get cachedData;
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
    Object? cachedData = freezed,
  }) {
    return _then(_$ErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
      cachedData: freezed == cachedData
          ? _value.cachedData
          : cachedData // ignore: cast_nullable_to_non_nullable
              as MembershipCard?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $MembershipCardCopyWith<$Res>? get cachedData {
    if (_value.cachedData == null) {
      return null;
    }

    return $MembershipCardCopyWith<$Res>(_value.cachedData!, (value) {
      return _then(_value.copyWith(cachedData: value));
    });
  }
}

/// @nodoc

class _$ErrorImpl extends _Error {
  const _$ErrorImpl({required this.failure, this.cachedData}) : super._();

  @override
  final Failure failure;
  @override
  final MembershipCard? cachedData;

  @override
  String toString() {
    return 'MembershipState.error(failure: $failure, cachedData: $cachedData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.cachedData, cachedData) ||
                other.cachedData == cachedData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure, cachedData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return error(failure, cachedData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return error?.call(failure, cachedData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure, cachedData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error extends MembershipState {
  const factory _Error(
      {required final Failure failure,
      final MembershipCard? cachedData}) = _$ErrorImpl;
  const _Error._() : super._();

  Failure get failure;
  MembershipCard? get cachedData;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmptyImplCopyWith<$Res> {
  factory _$$EmptyImplCopyWith(
          _$EmptyImpl value, $Res Function(_$EmptyImpl) then) =
      __$$EmptyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmptyImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$EmptyImpl>
    implements _$$EmptyImplCopyWith<$Res> {
  __$$EmptyImplCopyWithImpl(
      _$EmptyImpl _value, $Res Function(_$EmptyImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$EmptyImpl extends _Empty {
  const _$EmptyImpl() : super._();

  @override
  String toString() {
    return 'MembershipState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EmptyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class _Empty extends MembershipState {
  const factory _Empty() = _$EmptyImpl;
  const _Empty._() : super._();
}

/// @nodoc
abstract class _$$PendingImplCopyWith<$Res> {
  factory _$$PendingImplCopyWith(
          _$PendingImpl value, $Res Function(_$PendingImpl) then) =
      __$$PendingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PendingImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$PendingImpl>
    implements _$$PendingImplCopyWith<$Res> {
  __$$PendingImplCopyWithImpl(
      _$PendingImpl _value, $Res Function(_$PendingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PendingImpl extends _Pending {
  const _$PendingImpl() : super._();

  @override
  String toString() {
    return 'MembershipState.pending()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PendingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return pending();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return pending?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return pending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return pending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending(this);
    }
    return orElse();
  }
}

abstract class _Pending extends MembershipState {
  const factory _Pending() = _$PendingImpl;
  const _Pending._() : super._();
}

/// @nodoc
abstract class _$$RejectedImplCopyWith<$Res> {
  factory _$$RejectedImplCopyWith(
          _$RejectedImpl value, $Res Function(_$RejectedImpl) then) =
      __$$RejectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RejectedImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$RejectedImpl>
    implements _$$RejectedImplCopyWith<$Res> {
  __$$RejectedImplCopyWithImpl(
      _$RejectedImpl _value, $Res Function(_$RejectedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RejectedImpl extends _Rejected {
  const _$RejectedImpl() : super._();

  @override
  String toString() {
    return 'MembershipState.rejected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RejectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(MembershipCard? previousData) loading,
    required TResult Function(MembershipCard membershipCard) loaded,
    required TResult Function(Failure failure, MembershipCard? cachedData)
        error,
    required TResult Function() empty,
    required TResult Function() pending,
    required TResult Function() rejected,
  }) {
    return rejected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(MembershipCard? previousData)? loading,
    TResult? Function(MembershipCard membershipCard)? loaded,
    TResult? Function(Failure failure, MembershipCard? cachedData)? error,
    TResult? Function()? empty,
    TResult? Function()? pending,
    TResult? Function()? rejected,
  }) {
    return rejected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(MembershipCard? previousData)? loading,
    TResult Function(MembershipCard membershipCard)? loaded,
    TResult Function(Failure failure, MembershipCard? cachedData)? error,
    TResult Function()? empty,
    TResult Function()? pending,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Pending value) pending,
    required TResult Function(_Rejected value) rejected,
  }) {
    return rejected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Pending value)? pending,
    TResult? Function(_Rejected value)? rejected,
  }) {
    return rejected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_Empty value)? empty,
    TResult Function(_Pending value)? pending,
    TResult Function(_Rejected value)? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected(this);
    }
    return orElse();
  }
}

abstract class _Rejected extends MembershipState {
  const factory _Rejected() = _$RejectedImpl;
  const _Rejected._() : super._();
}
