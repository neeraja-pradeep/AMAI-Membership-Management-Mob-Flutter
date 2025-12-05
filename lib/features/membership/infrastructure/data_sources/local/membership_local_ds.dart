import 'package:hive/hive.dart';

/// Keys for Membership Hive box
class MembershipBoxKeys {
  MembershipBoxKeys._();

  /// Box name for membership feature
  static const String boxName = 'membership_box';

  /// Key for membership status timestamp
  static const String membershipTimestampKey = 'membership_timestamp';
}

/// Abstract class defining the local data source contract
abstract class MembershipLocalDataSource {
  /// Gets the stored timestamp for membership data
  Future<String?> getTimestamp();

  /// Stores the timestamp from the API response
  Future<void> storeTimestamp(String timestamp);

  /// Clears the stored timestamp
  Future<void> clearTimestamp();
}

/// Implementation of MembershipLocalDataSource using Hive
class MembershipLocalDataSourceImpl implements MembershipLocalDataSource {
  const MembershipLocalDataSourceImpl({required this.box});

  final Box<dynamic> box;

  @override
  Future<String?> getTimestamp() async {
    try {
      return box.get(MembershipBoxKeys.membershipTimestampKey) as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> storeTimestamp(String timestamp) async {
    await box.put(MembershipBoxKeys.membershipTimestampKey, timestamp);
  }

  @override
  Future<void> clearTimestamp() async {
    await box.delete(MembershipBoxKeys.membershipTimestampKey);
  }
}
