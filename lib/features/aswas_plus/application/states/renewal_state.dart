import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/aswas_plus/domain/entities/digital_product.dart';

part 'renewal_state.freezed.dart';

/// State for renewal products screen
@freezed
class RenewalState with _$RenewalState {
  /// Initial state before data is loaded
  const factory RenewalState.initial() = _Initial;

  /// Loading state while fetching products
  const factory RenewalState.loading() = _Loading;

  /// Loaded state with both products
  const factory RenewalState.loaded({
    required DigitalProduct membershipProduct,
    required DigitalProduct aswasProduct,
    @Default(null) int? selectedProductId,
  }) = _Loaded;

  /// Error state
  const factory RenewalState.error({
    required Failure failure,
  }) = _Error;

  const RenewalState._();

  /// Whether state is loading
  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  /// Gets the selected product ID
  int? get selectedProduct => maybeWhen(
        loaded: (_, __, selectedId) => selectedId,
        orElse: () => null,
      );
}
