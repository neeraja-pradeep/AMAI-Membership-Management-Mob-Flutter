// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'digital_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DigitalProduct {
  /// Unique identifier
  int get id => throw _privateConstructorUsedError;

  /// Product name (e.g., "Membership", "Aswas Plus")
  String get productName => throw _privateConstructorUsedError;

  /// Product type (e.g., "membership", "insurance")
  String get productType => throw _privateConstructorUsedError;

  /// Product description
  String? get description => throw _privateConstructorUsedError;

  /// Fixed price for the product
  String get fixedPrice => throw _privateConstructorUsedError;

  /// Base price
  String? get basePrice => throw _privateConstructorUsedError;

  /// Fine amount
  String? get fine => throw _privateConstructorUsedError;

  /// Validity period in months
  int? get validityPeriodMonths => throw _privateConstructorUsedError;

  /// Whether the product is active
  bool get isActive => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DigitalProductCopyWith<DigitalProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DigitalProductCopyWith<$Res> {
  factory $DigitalProductCopyWith(
          DigitalProduct value, $Res Function(DigitalProduct) then) =
      _$DigitalProductCopyWithImpl<$Res, DigitalProduct>;
  @useResult
  $Res call(
      {int id,
      String productName,
      String productType,
      String? description,
      String fixedPrice,
      String? basePrice,
      String? fine,
      int? validityPeriodMonths,
      bool isActive});
}

/// @nodoc
class _$DigitalProductCopyWithImpl<$Res, $Val extends DigitalProduct>
    implements $DigitalProductCopyWith<$Res> {
  _$DigitalProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productName = null,
    Object? productType = null,
    Object? description = freezed,
    Object? fixedPrice = null,
    Object? basePrice = freezed,
    Object? fine = freezed,
    Object? validityPeriodMonths = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productType: null == productType
          ? _value.productType
          : productType // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      fixedPrice: null == fixedPrice
          ? _value.fixedPrice
          : fixedPrice // ignore: cast_nullable_to_non_nullable
              as String,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      fine: freezed == fine
          ? _value.fine
          : fine // ignore: cast_nullable_to_non_nullable
              as String?,
      validityPeriodMonths: freezed == validityPeriodMonths
          ? _value.validityPeriodMonths
          : validityPeriodMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DigitalProductImplCopyWith<$Res>
    implements $DigitalProductCopyWith<$Res> {
  factory _$$DigitalProductImplCopyWith(_$DigitalProductImpl value,
          $Res Function(_$DigitalProductImpl) then) =
      __$$DigitalProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String productName,
      String productType,
      String? description,
      String fixedPrice,
      String? basePrice,
      String? fine,
      int? validityPeriodMonths,
      bool isActive});
}

/// @nodoc
class __$$DigitalProductImplCopyWithImpl<$Res>
    extends _$DigitalProductCopyWithImpl<$Res, _$DigitalProductImpl>
    implements _$$DigitalProductImplCopyWith<$Res> {
  __$$DigitalProductImplCopyWithImpl(
      _$DigitalProductImpl _value, $Res Function(_$DigitalProductImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productName = null,
    Object? productType = null,
    Object? description = freezed,
    Object? fixedPrice = null,
    Object? basePrice = freezed,
    Object? fine = freezed,
    Object? validityPeriodMonths = freezed,
    Object? isActive = null,
  }) {
    return _then(_$DigitalProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productType: null == productType
          ? _value.productType
          : productType // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      fixedPrice: null == fixedPrice
          ? _value.fixedPrice
          : fixedPrice // ignore: cast_nullable_to_non_nullable
              as String,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String?,
      fine: freezed == fine
          ? _value.fine
          : fine // ignore: cast_nullable_to_non_nullable
              as String?,
      validityPeriodMonths: freezed == validityPeriodMonths
          ? _value.validityPeriodMonths
          : validityPeriodMonths // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$DigitalProductImpl extends _DigitalProduct {
  const _$DigitalProductImpl(
      {required this.id,
      required this.productName,
      required this.productType,
      this.description,
      required this.fixedPrice,
      this.basePrice,
      this.fine,
      this.validityPeriodMonths,
      this.isActive = true})
      : super._();

  /// Unique identifier
  @override
  final int id;

  /// Product name (e.g., "Membership", "Aswas Plus")
  @override
  final String productName;

  /// Product type (e.g., "membership", "insurance")
  @override
  final String productType;

  /// Product description
  @override
  final String? description;

  /// Fixed price for the product
  @override
  final String fixedPrice;

  /// Base price
  @override
  final String? basePrice;

  /// Fine amount
  @override
  final String? fine;

  /// Validity period in months
  @override
  final int? validityPeriodMonths;

  /// Whether the product is active
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'DigitalProduct(id: $id, productName: $productName, productType: $productType, description: $description, fixedPrice: $fixedPrice, basePrice: $basePrice, fine: $fine, validityPeriodMonths: $validityPeriodMonths, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DigitalProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productType, productType) ||
                other.productType == productType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fixedPrice, fixedPrice) ||
                other.fixedPrice == fixedPrice) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.fine, fine) || other.fine == fine) &&
            (identical(other.validityPeriodMonths, validityPeriodMonths) ||
                other.validityPeriodMonths == validityPeriodMonths) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, productName, productType,
      description, fixedPrice, basePrice, fine, validityPeriodMonths, isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DigitalProductImplCopyWith<_$DigitalProductImpl> get copyWith =>
      __$$DigitalProductImplCopyWithImpl<_$DigitalProductImpl>(
          this, _$identity);
}

abstract class _DigitalProduct extends DigitalProduct {
  const factory _DigitalProduct(
      {required final int id,
      required final String productName,
      required final String productType,
      final String? description,
      required final String fixedPrice,
      final String? basePrice,
      final String? fine,
      final int? validityPeriodMonths,
      final bool isActive}) = _$DigitalProductImpl;
  const _DigitalProduct._() : super._();

  @override

  /// Unique identifier
  int get id;
  @override

  /// Product name (e.g., "Membership", "Aswas Plus")
  String get productName;
  @override

  /// Product type (e.g., "membership", "insurance")
  String get productType;
  @override

  /// Product description
  String? get description;
  @override

  /// Fixed price for the product
  String get fixedPrice;
  @override

  /// Base price
  String? get basePrice;
  @override

  /// Fine amount
  String? get fine;
  @override

  /// Validity period in months
  int? get validityPeriodMonths;
  @override

  /// Whether the product is active
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$DigitalProductImplCopyWith<_$DigitalProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
