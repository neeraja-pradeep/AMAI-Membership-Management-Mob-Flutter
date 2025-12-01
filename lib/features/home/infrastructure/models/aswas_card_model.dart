import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/features/home/domain/entities/aswas_plus.dart';

part 'aswas_card_model.g.dart';

/// Infrastructure model for AswasPlus with JSON serialization
/// Maps API response to domain entity
@JsonSerializable()
class AswasCardModel {
  const AswasCardModel({
    required this.id,
    required this.policyNumber,
    required this.endDate,
    required this.policyStatus,
    this.productDescription,
    this.coverageAmount,
    this.premiumAmount,
    this.startDate,
    this.userId,
    this.productId,
    this.paymentId,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates model from JSON map
  factory AswasCardModel.fromJson(Map<String, dynamic> json) =>
      _$AswasCardModelFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'policy_number')
  final String policyNumber;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'policy_status')
  final String policyStatus;

  @JsonKey(name: 'product_description')
  final String? productDescription;

  @JsonKey(name: 'coverage_amount')
  final String? coverageAmount;

  @JsonKey(name: 'premium_amount')
  final String? premiumAmount;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'user')
  final int? userId;

  @JsonKey(name: 'product')
  final int? productId;

  @JsonKey(name: 'payment')
  final int? paymentId;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Converts model to JSON map
  Map<String, dynamic> toJson() => _$AswasCardModelToJson(this);

  /// Converts to domain entity
  AswasPlus toDomain() {
    return AswasPlus(
      id: id.toString(),
      policyNumber: policyNumber,
      validUntil: _parseDate(endDate),
      policyStatus: policyStatus,
      productDescription: productDescription,
      coverageAmount: coverageAmount,
      premiumAmount: premiumAmount,
      startDate: startDate != null ? _parseDate(startDate!) : null,
    );
  }

  /// Parses date string from API (format: yyyy-MM-dd)
  static DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Return current date as fallback
      return DateTime.now();
    }
  }
}

/// Response wrapper for paginated insurance policy list
@JsonSerializable()
class AswasListResponse {
  const AswasListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AswasListResponse.fromJson(Map<String, dynamic> json) =>
      _$AswasListResponseFromJson(json);

  @JsonKey(name: 'count')
  final int count;

  @JsonKey(name: 'results')
  final List<AswasCardModel> results;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  Map<String, dynamic> toJson() => _$AswasListResponseToJson(this);

  /// Gets the first active policy (for current user's active aswas plus)
  AswasCardModel? get firstActivePolicy {
    try {
      return results.firstWhere(
        (policy) => policy.policyStatus.toLowerCase() == 'active',
      );
    } catch (e) {
      return null;
    }
  }
}
