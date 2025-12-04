// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_payment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembershipPaymentResponse {
  /// Razorpay order ID
  String get orderId => throw _privateConstructorUsedError;

  /// Payment amount
  int get amount => throw _privateConstructorUsedError;

  /// Currency code (e.g., "INR")
  String get currency => throw _privateConstructorUsedError;

  /// Membership ID
  int get membershipId => throw _privateConstructorUsedError;

  /// Membership fee amount
  int get membershipFee => throw _privateConstructorUsedError;

  /// Fine amount (if any)
  int get fine => throw _privateConstructorUsedError;

  /// Number of delayed months
  int get delayedMonths => throw _privateConstructorUsedError;

  /// Fine per month
  int get finePerMonth => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MembershipPaymentResponseCopyWith<MembershipPaymentResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipPaymentResponseCopyWith<$Res> {
  factory $MembershipPaymentResponseCopyWith(MembershipPaymentResponse value,
          $Res Function(MembershipPaymentResponse) then) =
      _$MembershipPaymentResponseCopyWithImpl<$Res, MembershipPaymentResponse>;
  @useResult
  $Res call(
      {String orderId,
      int amount,
      String currency,
      int membershipId,
      int membershipFee,
      int fine,
      int delayedMonths,
      int finePerMonth});
}

/// @nodoc
class _$MembershipPaymentResponseCopyWithImpl<$Res,
        $Val extends MembershipPaymentResponse>
    implements $MembershipPaymentResponseCopyWith<$Res> {
  _$MembershipPaymentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? membershipId = null,
    Object? membershipFee = null,
    Object? fine = null,
    Object? delayedMonths = null,
    Object? finePerMonth = null,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      membershipId: null == membershipId
          ? _value.membershipId
          : membershipId // ignore: cast_nullable_to_non_nullable
              as int,
      membershipFee: null == membershipFee
          ? _value.membershipFee
          : membershipFee // ignore: cast_nullable_to_non_nullable
              as int,
      fine: null == fine
          ? _value.fine
          : fine // ignore: cast_nullable_to_non_nullable
              as int,
      delayedMonths: null == delayedMonths
          ? _value.delayedMonths
          : delayedMonths // ignore: cast_nullable_to_non_nullable
              as int,
      finePerMonth: null == finePerMonth
          ? _value.finePerMonth
          : finePerMonth // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipPaymentResponseImplCopyWith<$Res>
    implements $MembershipPaymentResponseCopyWith<$Res> {
  factory _$$MembershipPaymentResponseImplCopyWith(
          _$MembershipPaymentResponseImpl value,
          $Res Function(_$MembershipPaymentResponseImpl) then) =
      __$$MembershipPaymentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderId,
      int amount,
      String currency,
      int membershipId,
      int membershipFee,
      int fine,
      int delayedMonths,
      int finePerMonth});
}

/// @nodoc
class __$$MembershipPaymentResponseImplCopyWithImpl<$Res>
    extends _$MembershipPaymentResponseCopyWithImpl<$Res,
        _$MembershipPaymentResponseImpl>
    implements _$$MembershipPaymentResponseImplCopyWith<$Res> {
  __$$MembershipPaymentResponseImplCopyWithImpl(
      _$MembershipPaymentResponseImpl _value,
      $Res Function(_$MembershipPaymentResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? membershipId = null,
    Object? membershipFee = null,
    Object? fine = null,
    Object? delayedMonths = null,
    Object? finePerMonth = null,
  }) {
    return _then(_$MembershipPaymentResponseImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      membershipId: null == membershipId
          ? _value.membershipId
          : membershipId // ignore: cast_nullable_to_non_nullable
              as int,
      membershipFee: null == membershipFee
          ? _value.membershipFee
          : membershipFee // ignore: cast_nullable_to_non_nullable
              as int,
      fine: null == fine
          ? _value.fine
          : fine // ignore: cast_nullable_to_non_nullable
              as int,
      delayedMonths: null == delayedMonths
          ? _value.delayedMonths
          : delayedMonths // ignore: cast_nullable_to_non_nullable
              as int,
      finePerMonth: null == finePerMonth
          ? _value.finePerMonth
          : finePerMonth // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MembershipPaymentResponseImpl extends _MembershipPaymentResponse {
  const _$MembershipPaymentResponseImpl(
      {required this.orderId,
      required this.amount,
      required this.currency,
      required this.membershipId,
      required this.membershipFee,
      this.fine = 0,
      this.delayedMonths = 0,
      this.finePerMonth = 0})
      : super._();

  /// Razorpay order ID
  @override
  final String orderId;

  /// Payment amount
  @override
  final int amount;

  /// Currency code (e.g., "INR")
  @override
  final String currency;

  /// Membership ID
  @override
  final int membershipId;

  /// Membership fee amount
  @override
  final int membershipFee;

  /// Fine amount (if any)
  @override
  @JsonKey()
  final int fine;

  /// Number of delayed months
  @override
  @JsonKey()
  final int delayedMonths;

  /// Fine per month
  @override
  @JsonKey()
  final int finePerMonth;

  @override
  String toString() {
    return 'MembershipPaymentResponse(orderId: $orderId, amount: $amount, currency: $currency, membershipId: $membershipId, membershipFee: $membershipFee, fine: $fine, delayedMonths: $delayedMonths, finePerMonth: $finePerMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipPaymentResponseImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.membershipId, membershipId) ||
                other.membershipId == membershipId) &&
            (identical(other.membershipFee, membershipFee) ||
                other.membershipFee == membershipFee) &&
            (identical(other.fine, fine) || other.fine == fine) &&
            (identical(other.delayedMonths, delayedMonths) ||
                other.delayedMonths == delayedMonths) &&
            (identical(other.finePerMonth, finePerMonth) ||
                other.finePerMonth == finePerMonth));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, amount, currency,
      membershipId, membershipFee, fine, delayedMonths, finePerMonth);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipPaymentResponseImplCopyWith<_$MembershipPaymentResponseImpl>
      get copyWith => __$$MembershipPaymentResponseImplCopyWithImpl<
          _$MembershipPaymentResponseImpl>(this, _$identity);
}

abstract class _MembershipPaymentResponse extends MembershipPaymentResponse {
  const factory _MembershipPaymentResponse(
      {required final String orderId,
      required final int amount,
      required final String currency,
      required final int membershipId,
      required final int membershipFee,
      final int fine,
      final int delayedMonths,
      final int finePerMonth}) = _$MembershipPaymentResponseImpl;
  const _MembershipPaymentResponse._() : super._();

  @override

  /// Razorpay order ID
  String get orderId;
  @override

  /// Payment amount
  int get amount;
  @override

  /// Currency code (e.g., "INR")
  String get currency;
  @override

  /// Membership ID
  int get membershipId;
  @override

  /// Membership fee amount
  int get membershipFee;
  @override

  /// Fine amount (if any)
  int get fine;
  @override

  /// Number of delayed months
  int get delayedMonths;
  @override

  /// Fine per month
  int get finePerMonth;
  @override
  @JsonKey(ignore: true)
  _$$MembershipPaymentResponseImplCopyWith<_$MembershipPaymentResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
