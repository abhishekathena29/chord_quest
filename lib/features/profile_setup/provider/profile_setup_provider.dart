import 'package:flutter/material.dart';

import '../../../core/session/user_session.dart';

enum SkillLevel { beginner, intermediate, advanced }

extension SkillLevelX on SkillLevel {
  String get label => switch (this) {
    SkillLevel.beginner => 'Beginner',
    SkillLevel.intermediate => 'Intermediate',
    SkillLevel.advanced => 'Advanced',
  };
}

enum Experience { justStarting, underOneYear, oneToThree, threePlus }

extension ExperienceX on Experience {
  String get label => switch (this) {
    Experience.justStarting => 'Just starting',
    Experience.underOneYear => '< 1 year',
    Experience.oneToThree => '1-3 years',
    Experience.threePlus => '3+ years',
  };
}

enum PracticeGoal { learnSongs, improveTechnique, musicTheory, justForFun }

extension PracticeGoalX on PracticeGoal {
  String get label => switch (this) {
    PracticeGoal.learnSongs => 'Learn songs',
    PracticeGoal.improveTechnique => 'Improve technique',
    PracticeGoal.musicTheory => 'Music theory',
    PracticeGoal.justForFun => 'Just for fun',
  };
}

/// Minimal post-signup questionnaire: skill level, experience and goal.
/// Answers are saved (as enum names) to the player's Firestore profile.
class ProfileSetupProvider extends ChangeNotifier {
  SkillLevel? _skill;
  SkillLevel? get skill => _skill;

  Experience? _experience;
  Experience? get experience => _experience;

  PracticeGoal? _goal;
  PracticeGoal? get goal => _goal;

  bool get canContinue =>
      _skill != null && _experience != null && _goal != null;

  void selectSkill(SkillLevel value) {
    _skill = value;
    notifyListeners();
  }

  void selectExperience(Experience value) {
    _experience = value;
    notifyListeners();
  }

  void selectGoal(PracticeGoal value) {
    _goal = value;
    notifyListeners();
  }

  bool _saving = false;
  bool get saving => _saving;

  bool _disposed = false;

  /// Saves the answers (all null when [skipped]) and returns an error message
  /// to show, or null on success. On success the root auth gate swaps this
  /// screen out as soon as the local Firestore cache updates.
  Future<String?> save(UserSession session, {bool skipped = false}) async {
    if (_saving) return null;
    _saving = true;
    notifyListeners();
    try {
      await session.completeProfileSetup(
        skillLevel: skipped ? null : _skill?.name,
        experience: skipped ? null : _experience?.name,
        goal: skipped ? null : _goal?.name,
      );
      return null;
    } catch (e) {
      debugPrint('Profile setup failed: $e');
      return "Couldn't save your profile. Check your connection and try again.";
    } finally {
      _saving = false;
      // The screen is usually gone by now: the gate moved on to the shell.
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
