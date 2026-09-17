import 'package:flutter/material.dart';

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
/// UI-only scaffolding — wire these answers to a backend profile later.
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
}
