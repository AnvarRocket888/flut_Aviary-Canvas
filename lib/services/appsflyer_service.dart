import 'package:flutter/foundation.dart';

/// AppsFlyer event stubs.
/// Every method prints to the debug console and is tagged with TODO.
/// Replace the body of each method with the real AppsFlyer SDK call when
/// the SDK is integrated.
class AppsFlyerService {
  static final AppsFlyerService instance = AppsFlyerService._();
  AppsFlyerService._();

  void _log(String event, Map<String, dynamic> params) {
    // debugPrint('[AppsFlyer] event=$event  params=$params');
  }

  /// Fired on every cold and warm launch.
  void trackAppLaunch() {
    // TODO: replace with real AppsFlyer SDK call
    _log('app_launch', {});
  }

  /// Fired when a new aviary scheme is created.
  void trackSchemeCreated(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('scheme_created', params);
  }

  /// Fired when an existing scheme is saved.
  void trackSchemeSaved(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('scheme_saved', params);
  }

  /// Fired when a scheme is deleted.
  void trackSchemeDeleted(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('scheme_deleted', params);
  }

  /// Fired when the user exports a scheme as text.
  void trackSchemeExported(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('scheme_exported', params);
  }

  /// Fired when any aviary calculation is run.
  void trackCalculationRun(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('calculation_run', params);
  }

  /// Fired when an achievement is unlocked.
  void trackAchievementUnlocked(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('achievement_unlocked', params);
  }

  /// Fired when a trophy is earned.
  void trackTrophyEarned(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('trophy_earned', params);
  }

  /// Fired when the user levels up to a new rank.
  void trackRankUp(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('rank_up', params);
  }

  /// Fired on any canvas drawing interaction.
  void trackCanvasInteraction(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('canvas_interaction', params);
  }

  /// Fired on the first open of each calendar day.
  void trackDailyLogin(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('daily_login', params);
  }

  /// Fired whenever XP is awarded.
  void trackXPEarned(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('xp_earned', params);
  }

  /// Fired when the user views the Achievements screen.
  void trackAchievementsViewed() {
    // TODO: replace with real AppsFlyer SDK call
    _log('achievements_viewed', {});
  }

  /// Fired when the user views the Trophies screen.
  void trackTrophiesViewed() {
    // TODO: replace with real AppsFlyer SDK call
    _log('trophies_viewed', {});
  }

  /// Fired on streak milestone days (multiples of 7).
  void trackStreakMilestone(Map<String, dynamic> params) {
    // TODO: replace with real AppsFlyer SDK call
    _log('streak_milestone', params);
  }
}
