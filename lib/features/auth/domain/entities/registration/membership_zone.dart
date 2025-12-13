/// Membership Zone entity
/// Represents a geographical zone (state) in the membership system
class MembershipZone {
  final int id;
  final String zoneName;
  final int lft;
  final int rght;
  final int treeId;
  final int level;
  final int parentZone;

  const MembershipZone({
    required this.id,
    required this.zoneName,
    required this.lft,
    required this.rght,
    required this.treeId,
    required this.level,
    required this.parentZone,
  });

  factory MembershipZone.fromJson(Map<String, dynamic> json) {
    return MembershipZone(
      id: json['id'] as int,
      zoneName: json['zone_name'] as String,
      lft: json['lft'] as int,
      rght: json['rght'] as int,
      treeId: json['tree_id'] as int,
      level: json['level'] as int,
      parentZone: json['parent_zone'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone_name': zoneName,
      'lft': lft,
      'rght': rght,
      'tree_id': treeId,
      'level': level,
      'parent_zone': parentZone,
    };
  }
}

/// Paginated response for membership zones
class MembershipZonesResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<MembershipZone> results;

  const MembershipZonesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory MembershipZonesResponse.fromJson(Map<String, dynamic> json) {
    return MembershipZonesResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => MembershipZone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
