import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core/error/failure.dart';
import 'package:myapp/features/aswas_plus/application/states/renewal_state.dart';
import 'package:myapp/features/home/application/providers/home_providers.dart';

/// Product IDs for renewal
class RenewalProductIds {
  RenewalProductIds._();

  /// Membership product ID
  static const int membership = 2;

  /// Aswas Plus product ID
  static const int aswasPlus = 1;
}

/// Provider for Renewal State
final renewalStateProvider =
    StateNotifierProvider<RenewalNotifier, RenewalState>((ref) {
  return RenewalNotifier(ref);
});

/// Notifier for managing renewal state
class RenewalNotifier extends StateNotifier<RenewalState> {
  RenewalNotifier(this._ref) : super(const RenewalState.initial());

  final Ref _ref;

  /// Load both digital products for renewal
  Future<void> loadProducts() async {
    state = const RenewalState.loading();

    final repository = _ref.read(homeRepositoryProvider);

    // Fetch both products in parallel
    final results = await Future.wait([
      repository.getDigitalProduct(productId: RenewalProductIds.membership),
      repository.getDigitalProduct(productId: RenewalProductIds.aswasPlus),
    ]);

    final membershipResult = results[0];
    final aswasResult = results[1];

    // Check for errors
    if (membershipResult.isLeft()) {
      state = RenewalState.error(
        failure: membershipResult.fold((l) => l, (r) => throw Exception()),
      );
      return;
    }

    if (aswasResult.isLeft()) {
      state = RenewalState.error(
        failure: aswasResult.fold((l) => l, (r) => throw Exception()),
      );
      return;
    }

    final membershipProduct = membershipResult.getOrElse((_) => null);
    final aswasProduct = aswasResult.getOrElse((_) => null);

    if (membershipProduct == null || aswasProduct == null) {
      state = const RenewalState.error(
        failure: ServerFailure(message: 'Failed to load products'),
      );
      return;
    }

    state = RenewalState.loaded(
      membershipProduct: membershipProduct,
      aswasProduct: aswasProduct,
    );
  }

  /// Select a product
  void selectProduct(int productId) {
    state.maybeWhen(
      loaded: (membership, aswas, _) {
        state = RenewalState.loaded(
          membershipProduct: membership,
          aswasProduct: aswas,
          selectedProductId: productId,
        );
      },
      orElse: () {},
    );
  }

  /// Clear selection
  void clearSelection() {
    state.maybeWhen(
      loaded: (membership, aswas, _) {
        state = RenewalState.loaded(
          membershipProduct: membership,
          aswasProduct: aswas,
          selectedProductId: null,
        );
      },
      orElse: () {},
    );
  }
}
