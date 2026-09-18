// Gamification leaderboard from `POST /api/gamification/leaderboard`.
// Plain models (no codegen).

class LeaderEntry {
  final int rank;
  final int userId;
  final String name;
  final String avatar; // absolute URL (may be a default avatar)
  final int points;
  final int level;
  final int badges;

  const LeaderEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.points,
    required this.level,
    required this.badges,
  });

  factory LeaderEntry.fromJson(Map<String, dynamic> j) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return LeaderEntry(
      rank: asInt(j['rank']),
      userId: asInt(j['userId']),
      name: j['name']?.toString() ?? '',
      avatar: j['avatar']?.toString() ?? '',
      points: asInt(j['points']),
      level: asInt(j['level']),
      badges: asInt(j['badgeCount']),
    );
  }
}

/// One admin-configurable "how to collect points" rule from the leaderboard
/// response (`pointRules`).
class PointRule {
  final String action;
  final String label;
  final int points;
  final bool enabled;
  final String displayText;

  const PointRule({
    required this.action,
    required this.label,
    required this.points,
    required this.enabled,
    required this.displayText,
  });

  factory PointRule.fromJson(Map<String, dynamic> j) {
    return PointRule(
      action: j['action']?.toString() ?? '',
      label: j['label']?.toString() ?? '',
      points: j['points'] is num
          ? (j['points'] as num).toInt()
          : int.tryParse('${j['points']}') ?? 0,
      enabled: j['enabled'] != false, // default to shown unless explicitly false
      displayText: j['displayText']?.toString() ?? '',
    );
  }
}

/// One admin-configurable level-up rule from the leaderboard response
/// (`levelUpRules`), e.g. "Upgrade level for every 100 points".
class LevelUpRule {
  final String type; // points | completed_courses | badges_received
  final String label;
  final int threshold;
  final bool enabled;
  final String displayText;

  const LevelUpRule({
    required this.type,
    required this.label,
    required this.threshold,
    required this.enabled,
    required this.displayText,
  });

  factory LevelUpRule.fromJson(Map<String, dynamic> j) {
    return LevelUpRule(
      type: j['type']?.toString() ?? '',
      label: j['label']?.toString() ?? '',
      threshold: j['threshold'] is num
          ? (j['threshold'] as num).toInt()
          : int.tryParse('${j['threshold']}') ?? 0,
      enabled: j['enabled'] != false, // default to shown unless explicitly false
      displayText: j['displayText']?.toString() ?? '',
    );
  }
}

class Leaderboard {
  /// Signed-in learner summary (`currentUser`).
  final int rank;
  final int points;
  final int level;
  final int badgeCount;
  final List<LeaderEntry> entries;

  /// Admin-configured point rules ("How to collect points").
  final List<PointRule> pointRules;

  /// Admin-configured level-up rules ("How to level up").
  final List<LevelUpRule> levelUpRules;

  const Leaderboard({
    required this.rank,
    required this.points,
    required this.level,
    required this.badgeCount,
    required this.entries,
    this.pointRules = const [],
    this.levelUpRules = const [],
  });

  factory Leaderboard.fromData(Map<String, dynamic> data) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final cu = data['currentUser'] is Map
        ? Map<String, dynamic>.from(data['currentUser'] as Map)
        : <String, dynamic>{};
    final lb = data['leaderboard'] is List
        ? (data['leaderboard'] as List)
        : const [];
    final pr = data['pointRules'] is List
        ? (data['pointRules'] as List)
        : const [];
    final lr = data['levelUpRules'] is List
        ? (data['levelUpRules'] as List)
        : const [];
    return Leaderboard(
      rank: asInt(cu['rank']),
      points: asInt(cu['points']),
      level: asInt(cu['level']),
      badgeCount: asInt(cu['badgeCount']),
      entries: lb
          .whereType<Map>()
          .map((e) => LeaderEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pointRules: pr
          .whereType<Map>()
          .map((e) => PointRule.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      levelUpRules: lr
          .whereType<Map>()
          .map((e) => LevelUpRule.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
