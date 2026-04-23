/// Persisted user state: XP, streak, stats, unlocked achievements/trophies.
class UserProfile {
  final int xp;
  final int streakDays;
  final String? lastLoginDate;        // 'yyyy-MM-dd'
  final int totalSchemesCreated;
  final int totalCalculationsRun;
  final int totalBirdsAdded;
  final int conflictsResolved;
  final List<String> unlockedAchievementIds;
  final List<String> unlockedTrophyIds;
  final List<String> usedBirdSpecies;

  const UserProfile({
    this.xp                      = 0,
    this.streakDays              = 0,
    this.lastLoginDate,
    this.totalSchemesCreated     = 0,
    this.totalCalculationsRun    = 0,
    this.totalBirdsAdded         = 0,
    this.conflictsResolved       = 0,
    this.unlockedAchievementIds  = const [],
    this.unlockedTrophyIds       = const [],
    this.usedBirdSpecies         = const [],
  });

  UserProfile copyWith({
    int?          xp,
    int?          streakDays,
    String?       lastLoginDate,
    int?          totalSchemesCreated,
    int?          totalCalculationsRun,
    int?          totalBirdsAdded,
    int?          conflictsResolved,
    List<String>? unlockedAchievementIds,
    List<String>? unlockedTrophyIds,
    List<String>? usedBirdSpecies,
  }) {
    return UserProfile(
      xp:                     xp                     ?? this.xp,
      streakDays:             streakDays             ?? this.streakDays,
      lastLoginDate:          lastLoginDate          ?? this.lastLoginDate,
      totalSchemesCreated:    totalSchemesCreated    ?? this.totalSchemesCreated,
      totalCalculationsRun:   totalCalculationsRun   ?? this.totalCalculationsRun,
      totalBirdsAdded:        totalBirdsAdded        ?? this.totalBirdsAdded,
      conflictsResolved:      conflictsResolved      ?? this.conflictsResolved,
      unlockedAchievementIds: unlockedAchievementIds ?? this.unlockedAchievementIds,
      unlockedTrophyIds:      unlockedTrophyIds      ?? this.unlockedTrophyIds,
      usedBirdSpecies:        usedBirdSpecies        ?? this.usedBirdSpecies,
    );
  }

  Map<String, dynamic> toJson() => {
    'xp':                     xp,
    'streakDays':             streakDays,
    'lastLoginDate':          lastLoginDate,
    'totalSchemesCreated':    totalSchemesCreated,
    'totalCalculationsRun':   totalCalculationsRun,
    'totalBirdsAdded':        totalBirdsAdded,
    'conflictsResolved':      conflictsResolved,
    'unlockedAchievementIds': unlockedAchievementIds,
    'unlockedTrophyIds':      unlockedTrophyIds,
    'usedBirdSpecies':        usedBirdSpecies,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    xp:                     (j['xp']                  as int?) ?? 0,
    streakDays:             (j['streakDays']           as int?) ?? 0,
    lastLoginDate:           j['lastLoginDate']        as String?,
    totalSchemesCreated:    (j['totalSchemesCreated']  as int?) ?? 0,
    totalCalculationsRun:   (j['totalCalculationsRun'] as int?) ?? 0,
    totalBirdsAdded:        (j['totalBirdsAdded']      as int?) ?? 0,
    conflictsResolved:      (j['conflictsResolved']    as int?) ?? 0,
    unlockedAchievementIds: List<String>.from(j['unlockedAchievementIds'] as List? ?? []),
    unlockedTrophyIds:      List<String>.from(j['unlockedTrophyIds']      as List? ?? []),
    usedBirdSpecies:        List<String>.from(j['usedBirdSpecies']        as List? ?? []),
  );
}
